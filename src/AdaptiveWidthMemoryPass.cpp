#include "llvm/Analysis/ValueTracking.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/KnownBits.h"
#include "llvm/Support/raw_ostream.h"

#include <algorithm>
#include <string>

using namespace llvm;

namespace {

struct SafetySummary {
  unsigned SupportedUses = 0;
  unsigned UnsupportedUses = 0;
  unsigned LoadUses = 0;
  unsigned StoreUses = 0;
  const char *FirstUnsupportedReason = nullptr;
  SmallVector<std::string, 4> Rejections;
};

struct WidthSummary {
  unsigned OriginalBits = 0;
  unsigned RequiredBits = 1;
  unsigned ProposedBits = 1;
  bool HasUnknownStoredValue = false;
  bool UsedInferredValue = false;
  enum class ExtensionKind { Unknown, Zero, Sign };
  ExtensionKind Extension = ExtensionKind::Unknown;
};

struct RunStats {
  unsigned CandidateGlobals = 0;
  unsigned CandidateAllocas = 0;
  unsigned SafeCandidates = 0;
  unsigned BlockedCandidates = 0;
  unsigned UnknownWidthCandidates = 0;
  unsigned NoMeaningfulReductionCandidates = 0;
  unsigned RewriteBlockedCandidates = 0;
  unsigned NoTargetAllocationBenefitCandidates = 0;
  unsigned TransformedGlobals = 0;
  unsigned TransformedAllocas = 0;
  unsigned LoadsRewritten = 0;
  unsigned StoresRewritten = 0;
  uint64_t BitsSavedPerElement = 0;
};

struct PassConfig {
  bool Transform = true;
  bool ProcessGlobals = true;
  bool ProcessAllocas = true;
  bool RequireTargetAllocationBenefit = false;
  StringRef ModeName = "adaptive-width-mem";
};

bool isIntegerOrIntegerArray(Type *Ty) {
  if (Ty->isIntegerTy())
    return true;

  auto *ArrayTy = dyn_cast<ArrayType>(Ty);
  return ArrayTy && isIntegerOrIntegerArray(ArrayTy->getElementType());
}

IntegerType *getIntegerElementType(Type *Ty) {
  if (auto *IntTy = dyn_cast<IntegerType>(Ty))
    return IntTy;

  auto *ArrayTy = dyn_cast<ArrayType>(Ty);
  if (!ArrayTy)
    return nullptr;

  return getIntegerElementType(ArrayTy->getElementType());
}

Type *replaceIntegerElementType(Type *Ty, IntegerType *NewElementTy) {
  if (Ty->isIntegerTy())
    return NewElementTy;

  auto *ArrayTy = cast<ArrayType>(Ty);
  Type *NewNestedTy =
      replaceIntegerElementType(ArrayTy->getElementType(), NewElementTy);
  return ArrayType::get(NewNestedTy, ArrayTy->getNumElements());
}

StringRef linkageName(GlobalValue::LinkageTypes Linkage) {
  switch (Linkage) {
  case GlobalValue::PrivateLinkage:
    return "private";
  case GlobalValue::InternalLinkage:
    return "internal";
  default:
    return "other";
  }
}

void printValueName(raw_ostream &OS, const Value &V) {
  if (V.hasName()) {
    OS << V.getName();
    return;
  }

  OS << "<unnamed>";
}

class AdaptiveWidthMemoryPass
    : public PassInfoMixin<AdaptiveWidthMemoryPass> {
public:
  explicit AdaptiveWidthMemoryPass(PassConfig Config = {}) : Config(Config) {}

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &) {
    errs() << "[adaptive-width-mem] module=" << M.getName()
           << " mode=" << Config.ModeName << "\n";
    DL = &M.getDataLayout();
    bool Changed = false;

    if (Config.ProcessGlobals) {
      SmallVector<GlobalVariable *, 8> Globals;
      for (GlobalVariable &GV : M.globals())
        Globals.push_back(&GV);

      for (GlobalVariable *GV : Globals)
        Changed |= processGlobalCandidate(*GV);
    }

    if (Config.ProcessAllocas)
      for (Function &F : M)
        if (!F.isDeclaration())
          Changed |= processFunctionCandidates(F);

    logSummary();

    return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
  }

  static bool isRequired() { return true; }

private:
  PassConfig Config;
  RunStats Stats;
  const DataLayout *DL = nullptr;

  bool processGlobalCandidate(GlobalVariable &GV) {
    if (!GV.hasLocalLinkage())
      return false;

    Type *ValueTy = GV.getValueType();
    if (!isIntegerOrIntegerArray(ValueTy))
      return false;

    ++Stats.CandidateGlobals;
    errs() << "[adaptive-width-mem] candidate global name=" << GV.getName()
           << " linkage=" << linkageName(GV.getLinkage()) << " type=";
    ValueTy->print(errs());
    CandidateSummary Summary = logSafetyAndWidth(GV, ValueTy);
    if (!Config.Transform)
      return false;
    return tryNarrowGlobal(GV, ValueTy, Summary);
  }

  bool processFunctionCandidates(Function &F) {
    bool Changed = false;
    SmallVector<AllocaInst *, 8> Allocas;

    for (BasicBlock &BB : F)
      for (Instruction &I : BB)
        if (auto *AI = dyn_cast<AllocaInst>(&I))
          Allocas.push_back(AI);

    for (AllocaInst *AI : Allocas)
      Changed |= processAllocaCandidate(F, *AI);

    return Changed;
  }

  bool processAllocaCandidate(Function &F, AllocaInst &AI) {
    Type *AllocatedTy = AI.getAllocatedType();
    if (!isa<ArrayType>(AllocatedTy) || !isIntegerOrIntegerArray(AllocatedTy))
      return false;

    ++Stats.CandidateAllocas;
    errs() << "[adaptive-width-mem] candidate alloca function=" << F.getName()
           << " name=" << AI.getName() << " type=";
    AllocatedTy->print(errs());
    CandidateSummary Summary = logSafetyAndWidth(AI, AllocatedTy);
    if (!Config.Transform)
      return false;
    return tryNarrowAlloca(AI, AllocatedTy, Summary);
  }

  struct CandidateSummary {
    SafetySummary Safety;
    WidthSummary Width;
  };

  CandidateSummary logSafetyAndWidth(Value &Root, Type *StoredTy) {
    CandidateSummary Candidate;
    SafetySummary Summary;
    SmallPtrSet<const Value *, 16> Visited;
    analyzePointerUsers(Root, Root, Summary, Visited);
    Candidate.Safety = Summary;
    if (Summary.UnsupportedUses == 0)
      ++Stats.SafeCandidates;
    else
      ++Stats.BlockedCandidates;

    errs() << " safety=" << (Summary.UnsupportedUses == 0 ? "safe" : "blocked")
           << " reason=";
    if (Summary.UnsupportedUses == 0 && Summary.SupportedUses == 0)
      errs() << "no-uses";
    else if (Summary.UnsupportedUses == 0)
      errs() << "supported-uses-only";
    else
      errs() << Summary.FirstUnsupportedReason;

    errs() << " supported-uses=" << Summary.SupportedUses
           << " unsupported-uses=" << Summary.UnsupportedUses;

    if (Summary.UnsupportedUses == 0) {
      Candidate.Width = computeWidth(Root, StoredTy);
      logWidth(Candidate.Width, Summary);
    }
    else
      errs() << " width=blocked";

    errs() << "\n";

    for (StringRef Rejection : Summary.Rejections)
      errs() << Rejection << "\n";

    return Candidate;
  }

  WidthSummary computeWidth(Value &Root, Type *StoredTy) {
    WidthSummary Width;
    IntegerType *ElementTy = getIntegerElementType(StoredTy);
    if (!ElementTy) {
      Width.HasUnknownStoredValue = true;
      return Width;
    }

    Width.OriginalBits = ElementTy->getBitWidth();
    collectInitialStoredBits(Root, Width);

    SmallPtrSet<const Value *, 16> Visited;
    collectStoredBits(Root, Width, Visited);

    Width.ProposedBits =
        Width.HasUnknownStoredValue ? Width.OriginalBits : Width.RequiredBits;
    if (Width.ProposedBits > Width.OriginalBits)
      Width.ProposedBits = Width.OriginalBits;

    return Width;
  }

  void logWidth(const WidthSummary &Width, const SafetySummary &Safety) {
    if (Width.OriginalBits == 0) {
      errs() << " width=blocked width-reason=non-integer-element";
      return;
    }
    errs() << " original-bits=" << Width.OriginalBits
           << " proposed-bits=" << Width.ProposedBits
           << " width-reason=" << widthReason(Width)
           << " extend=" << extensionName(Width.Extension)
           << " loads=" << Safety.LoadUses << " stores=" << Safety.StoreUses;
  }

  StringRef extensionName(WidthSummary::ExtensionKind Extension) {
    switch (Extension) {
    case WidthSummary::ExtensionKind::Zero:
      return "zext";
    case WidthSummary::ExtensionKind::Sign:
      return "sext";
    case WidthSummary::ExtensionKind::Unknown:
      return "unknown";
    }
    llvm_unreachable("Unhandled extension kind");
  }

  void mergeExtension(WidthSummary &Width,
                      WidthSummary::ExtensionKind Extension) {
    if (Width.Extension == WidthSummary::ExtensionKind::Unknown) {
      Width.Extension = Extension;
      return;
    }

    if (Width.Extension != Extension)
      Width.HasUnknownStoredValue = true;
  }

  bool tryNarrowAlloca(AllocaInst &AI, Type *AllocatedTy,
                       const CandidateSummary &Candidate) {
    const SafetySummary &Safety = Candidate.Safety;
    const WidthSummary &Width = Candidate.Width;
    if (Safety.UnsupportedUses != 0 || Width.HasUnknownStoredValue ||
        Width.ProposedBits >= Width.OriginalBits) {
      noteWidthSkip(Width);
      return false;
    }

    auto *OldElementTy = getIntegerElementType(AllocatedTy);
    if (!OldElementTy)
      return false;

    IntegerType *NewElementTy =
        IntegerType::get(AI.getContext(), Width.ProposedBits);
    if (!canRewritePointerUsers(AI, *OldElementTy, *NewElementTy)) {
      ++Stats.RewriteBlockedCandidates;
      return false;
    }

    Type *NewAllocatedTy = replaceIntegerElementType(AllocatedTy, NewElementTy);
    if (!hasTargetAllocationBenefit(AI, AllocatedTy, NewAllocatedTy))
      return false;
    auto *NewAI = new AllocaInst(NewAllocatedTy, AI.getAddressSpace(),
                                 AI.getArraySize(), AI.getAlign(),
                                 AI.getName() + ".narrow", &AI);

    SmallVector<Instruction *, 8> DeadInstructions;
    SmallPtrSet<Value *, 16> Visited;
    rewritePointerUsers(AI, *NewAI, NewElementTy, Width.Extension,
                        DeadInstructions, Visited);

    for (Instruction *Dead : DeadInstructions)
      if (Dead->use_empty())
        Dead->eraseFromParent();

    if (AI.use_empty())
      AI.eraseFromParent();

    errs() << "[adaptive-width-mem] transform alloca name=" << NewAI->getName()
           << " original-bits=" << Width.OriginalBits
           << " narrowed-bits=" << Width.ProposedBits << " original-type=\"";
    AllocatedTy->print(errs());
    errs() << "\" transformed-type=\"";
    NewAllocatedTy->print(errs());
    errs() << "\" original-alloc-bytes="
           << DL->getTypeAllocSize(AllocatedTy).getFixedValue()
           << " transformed-alloc-bytes="
           << DL->getTypeAllocSize(NewAllocatedTy).getFixedValue()
           << " original-abi-align=" << DL->getABITypeAlign(AllocatedTy).value()
           << " transformed-abi-align="
           << DL->getABITypeAlign(NewAllocatedTy).value() << "\n";
    ++Stats.TransformedAllocas;
    Stats.BitsSavedPerElement += Width.OriginalBits - Width.ProposedBits;
    return true;
  }

  bool tryNarrowGlobal(GlobalVariable &GV, Type *ValueTy,
                       const CandidateSummary &Candidate) {
    const SafetySummary &Safety = Candidate.Safety;
    const WidthSummary &Width = Candidate.Width;
    if (Safety.UnsupportedUses != 0 || Width.HasUnknownStoredValue ||
        Width.ProposedBits >= Width.OriginalBits || GV.isExternallyInitialized()) {
      noteWidthSkip(Width);
      return false;
    }

    auto *OldElementTy = getIntegerElementType(ValueTy);
    if (!OldElementTy)
      return false;

    IntegerType *NewElementTy =
        IntegerType::get(GV.getContext(), Width.ProposedBits);
    if (!canRewritePointerUsers(GV, *OldElementTy, *NewElementTy)) {
      ++Stats.RewriteBlockedCandidates;
      return false;
    }

    Type *NewValueTy = replaceIntegerElementType(ValueTy, NewElementTy);
    if (!hasTargetAllocationBenefit(GV, ValueTy, NewValueTy))
      return false;
    Constant *NewInitializer = nullptr;
    if (GV.hasInitializer())
      NewInitializer = narrowConstant(GV.getInitializer(), NewValueTy);

    auto *NewGV = new GlobalVariable(
        *GV.getParent(), NewValueTy, GV.isConstant(), GV.getLinkage(),
        NewInitializer, GV.getName() + ".narrow", &GV, GV.getThreadLocalMode(),
        GV.getAddressSpace(), GV.isExternallyInitialized());
    NewGV->copyAttributesFrom(&GV);
    NewGV->setAlignment(GV.getAlign());
    NewGV->setUnnamedAddr(GV.getUnnamedAddr());

    SmallVector<Instruction *, 8> DeadInstructions;
    SmallPtrSet<Value *, 16> Visited;
    rewritePointerUsers(GV, *NewGV, NewElementTy, Width.Extension,
                        DeadInstructions, Visited);

    for (Instruction *Dead : DeadInstructions)
      if (Dead->use_empty())
        Dead->eraseFromParent();

    if (GV.use_empty())
      GV.eraseFromParent();

    errs() << "[adaptive-width-mem] transform global name=" << NewGV->getName()
           << " original-bits=" << Width.OriginalBits
           << " narrowed-bits=" << Width.ProposedBits << " original-type=\"";
    ValueTy->print(errs());
    errs() << "\" transformed-type=\"";
    NewValueTy->print(errs());
    errs() << "\" original-alloc-bytes="
           << DL->getTypeAllocSize(ValueTy).getFixedValue()
           << " transformed-alloc-bytes="
           << DL->getTypeAllocSize(NewValueTy).getFixedValue()
           << " original-abi-align=" << DL->getABITypeAlign(ValueTy).value()
           << " transformed-abi-align=" << DL->getABITypeAlign(NewValueTy).value()
           << "\n";
    ++Stats.TransformedGlobals;
    Stats.BitsSavedPerElement += Width.OriginalBits - Width.ProposedBits;
    return true;
  }

  void noteWidthSkip(const WidthSummary &Width) {
    if (Width.HasUnknownStoredValue)
      ++Stats.UnknownWidthCandidates;
    else if (Width.OriginalBits != 0 && Width.ProposedBits >= Width.OriginalBits)
      ++Stats.NoMeaningfulReductionCandidates;
  }

  bool hasTargetAllocationBenefit(Value &Root, Type *OriginalTy,
                                  Type *TransformedTy) {
    if (!Config.RequireTargetAllocationBenefit)
      return true;

    uint64_t BaselineBytes =
        DL->getTypeAllocSize(OriginalTy).getFixedValue();
    uint64_t TransformedBytes =
        DL->getTypeAllocSize(TransformedTy).getFixedValue();
    if (TransformedBytes < BaselineBytes)
      return true;

    ++Stats.NoTargetAllocationBenefitCandidates;
    errs() << "[adaptive-width-mem] reject candidate=";
    printValueName(errs(), Root);
    errs() << " reason=no-target-allocation-benefit"
           << " baseline-alloc-bytes=" << BaselineBytes
           << " transformed-alloc-bytes=" << TransformedBytes << "\n";
    return false;
  }

  Constant *narrowConstant(Constant *C, Type *NewTy) {
    if (isa<ConstantAggregateZero>(C))
      return ConstantAggregateZero::get(NewTy);
    if (isa<UndefValue>(C))
      return UndefValue::get(NewTy);
    if (isa<PoisonValue>(C))
      return PoisonValue::get(NewTy);

    if (auto *CI = dyn_cast<ConstantInt>(C)) {
      auto *NewIntTy = cast<IntegerType>(NewTy);
      APInt Narrowed = CI->getValue().trunc(NewIntTy->getBitWidth());
      return ConstantInt::get(NewIntTy, Narrowed);
    }

    if (auto *ArrayTy = dyn_cast<ArrayType>(NewTy)) {
      SmallVector<Constant *, 8> Elements;
      auto *CA = cast<ConstantAggregate>(C);
      for (Use &Operand : CA->operands())
        Elements.push_back(
            narrowConstant(cast<Constant>(Operand.get()),
                           ArrayTy->getElementType()));
      return ConstantArray::get(ArrayTy, Elements);
    }

    return UndefValue::get(NewTy);
  }

  bool canRewritePointerUsers(Value &Ptr, IntegerType &OldElementTy,
                              IntegerType &NewElementTy) {
    SmallPtrSet<const Value *, 16> Visited;
    return canRewritePointerUsersImpl(Ptr, OldElementTy, NewElementTy, Visited);
  }

  bool canRewritePointerUsersImpl(Value &Ptr, IntegerType &OldElementTy,
                                  IntegerType &NewElementTy,
                                  SmallPtrSetImpl<const Value *> &Visited) {
    if (!Visited.insert(&Ptr).second)
      return true;

    for (Use &U : Ptr.uses()) {
      User *Usr = U.getUser();

      if (auto *GEP = dyn_cast<GetElementPtrInst>(Usr)) {
        if (!canRewritePointerUsersImpl(*GEP, OldElementTy, NewElementTy,
                                        Visited))
          return false;
        continue;
      }

      if (auto *LI = dyn_cast<LoadInst>(Usr)) {
        if (LI->getPointerOperand() != &Ptr || LI->getType() != &OldElementTy)
          return false;
        if (LI->isVolatile() || LI->isAtomic())
          return false;
        continue;
      }

      if (auto *SI = dyn_cast<StoreInst>(Usr)) {
        if (SI->getPointerOperand() != &Ptr ||
            SI->getValueOperand()->getType() != &OldElementTy)
          return false;
        if (SI->isVolatile() || SI->isAtomic())
          return false;
        continue;
      }

      if (isa<BitCastInst>(Usr) || isa<AddrSpaceCastInst>(Usr))
        return false;

      return false;
    }

    return true;
  }

  void rewritePointerUsers(Value &OldPtr, Value &NewPtr, IntegerType *NewElementTy,
                           WidthSummary::ExtensionKind Extension,
                           SmallVectorImpl<Instruction *> &DeadInstructions,
                           SmallPtrSetImpl<Value *> &Visited) {
    if (!Visited.insert(&OldPtr).second)
      return;

    SmallVector<User *, 8> Users(OldPtr.user_begin(), OldPtr.user_end());
    for (User *Usr : Users) {
      if (auto *GEP = dyn_cast<GetElementPtrInst>(Usr)) {
        IRBuilder<> Builder(GEP);
        SmallVector<Value *, 4> Indices(GEP->idx_begin(), GEP->idx_end());
        Type *NewSourceTy =
            replaceIntegerElementType(GEP->getSourceElementType(), NewElementTy);
        Value *NewGEP = GEP->isInBounds()
                            ? Builder.CreateInBoundsGEP(
                                  NewSourceTy, &NewPtr, Indices,
                                  GEP->getName() + ".narrow")
                            : Builder.CreateGEP(NewSourceTy, &NewPtr, Indices,
                                                GEP->getName() + ".narrow");
        rewritePointerUsers(*GEP, *NewGEP, NewElementTy, Extension,
                            DeadInstructions, Visited);
        DeadInstructions.push_back(GEP);
        continue;
      }

      if (auto *LI = dyn_cast<LoadInst>(Usr)) {
        if (LI->getPointerOperand() != &OldPtr)
          continue;

        IRBuilder<> Builder(LI);
        LoadInst *NewLoad = Builder.CreateAlignedLoad(
            NewElementTy, &NewPtr, LI->getAlign(), LI->getName() + ".narrow");
        Value *Extended =
            Extension == WidthSummary::ExtensionKind::Sign
                ? Builder.CreateSExt(NewLoad, LI->getType(),
                                     LI->getName() + ".wide")
                : Builder.CreateZExt(NewLoad, LI->getType(),
                                     LI->getName() + ".wide");
        LI->replaceAllUsesWith(Extended);
        DeadInstructions.push_back(LI);
        ++Stats.LoadsRewritten;
        continue;
      }

      if (auto *SI = dyn_cast<StoreInst>(Usr)) {
        if (SI->getPointerOperand() != &OldPtr)
          continue;

        IRBuilder<> Builder(SI);
        Value *Stored = SI->getValueOperand();
        if (Stored->getType() != NewElementTy)
          Stored = Builder.CreateTrunc(Stored, NewElementTy,
                                       Stored->getName() + ".narrow");
        SI->setOperand(0, Stored);
        SI->setOperand(1, &NewPtr);
        ++Stats.StoresRewritten;
      }
    }
  }

  void logSummary() {
    errs() << "[adaptive-width-mem] summary"
           << " candidate-globals=" << Stats.CandidateGlobals
           << " candidate-allocas=" << Stats.CandidateAllocas
           << " safe=" << Stats.SafeCandidates
           << " blocked=" << Stats.BlockedCandidates
           << " unknown-width=" << Stats.UnknownWidthCandidates
           << " no-meaningful-reduction="
           << Stats.NoMeaningfulReductionCandidates
           << " rewrite-blocked=" << Stats.RewriteBlockedCandidates
           << " transformed-globals=" << Stats.TransformedGlobals
           << " transformed-allocas=" << Stats.TransformedAllocas
           << " loads-rewritten=" << Stats.LoadsRewritten
           << " stores-rewritten=" << Stats.StoresRewritten
           << " bits-saved-per-element=" << Stats.BitsSavedPerElement
           << " no-target-allocation-benefit="
           << Stats.NoTargetAllocationBenefitCandidates
           << "\n";
  }

  StringRef widthReason(const WidthSummary &Width) {
    if (Width.HasUnknownStoredValue)
      return "unknown-stored-value";
    if (Width.UsedInferredValue)
      return "inferred-stored-values";
    return "constant-stored-values";
  }

  void collectInitialStoredBits(Value &Root, WidthSummary &Width) {
    auto *GV = dyn_cast<GlobalVariable>(&Root);
    if (!GV || !GV->hasInitializer())
      return;

    collectConstantBits(GV->getInitializer(), Width);
  }

  void collectConstantBits(Constant *C, WidthSummary &Width) {
    if (isa<ConstantAggregateZero>(C) || isa<UndefValue>(C) ||
        isa<PoisonValue>(C)) {
      Width.RequiredBits = std::max(Width.RequiredBits, 1u);
      mergeExtension(Width, WidthSummary::ExtensionKind::Zero);
      return;
    }

    if (auto *CI = dyn_cast<ConstantInt>(C)) {
      unsigned Bits = CI->getValue().getActiveBits();
      Width.RequiredBits = std::max(Width.RequiredBits, std::max(Bits, 1u));
      mergeExtension(Width, WidthSummary::ExtensionKind::Zero);
      return;
    }

    if (auto *CA = dyn_cast<ConstantAggregate>(C)) {
      for (Use &Operand : CA->operands())
        collectConstantBits(cast<Constant>(Operand.get()), Width);
      return;
    }

    Width.HasUnknownStoredValue = true;
  }

  void collectStoredBits(Value &Ptr, WidthSummary &Width,
                         SmallPtrSetImpl<const Value *> &Visited) {
    if (!Visited.insert(&Ptr).second)
      return;

    for (Use &U : Ptr.uses()) {
      User *Usr = U.getUser();

      if (auto *GEP = dyn_cast<GetElementPtrInst>(Usr)) {
        collectStoredBits(*GEP, Width, Visited);
        continue;
      }

      if (auto *SI = dyn_cast<StoreInst>(Usr)) {
        if (SI->getPointerOperand() != &Ptr)
          continue;

        unsigned Bits = 0;
        bool UsedInference = false;
        WidthSummary::ExtensionKind Extension =
            WidthSummary::ExtensionKind::Unknown;
        SmallPtrSet<Value *, 16> InferVisited;
        if (!inferRequiredBits(SI->getValueOperand(), Bits, UsedInference,
                               Extension, InferVisited)) {
          Width.HasUnknownStoredValue = true;
          continue;
        }

        Width.RequiredBits = std::max(Width.RequiredBits, std::max(Bits, 1u));
        Width.UsedInferredValue |= UsedInference;
        mergeExtension(Width, Extension);
        continue;
      }

      if (auto *BC = dyn_cast<BitCastInst>(Usr)) {
        collectStoredBits(*BC, Width, Visited);
        continue;
      }

      if (auto *ASC = dyn_cast<AddrSpaceCastInst>(Usr))
        collectStoredBits(*ASC, Width, Visited);
    }
  }

  bool inferRequiredBits(Value *V, unsigned &Bits, bool &UsedInference,
                         WidthSummary::ExtensionKind &Extension,
                         SmallPtrSetImpl<Value *> &Visited) {
    if (auto *CI = dyn_cast<ConstantInt>(V)) {
      Bits = std::max(CI->getValue().getActiveBits(), 1u);
      Extension = WidthSummary::ExtensionKind::Zero;
      return true;
    }

    auto *I = dyn_cast<Instruction>(V);
    if (!I)
      return false;

    if (!Visited.insert(V).second)
      return false;

    switch (I->getOpcode()) {
    case Instruction::Trunc:
      Bits = cast<IntegerType>(I->getType())->getBitWidth();
      Extension = WidthSummary::ExtensionKind::Zero;
      {
        unsigned OperandBits = 0;
        bool OperandInference = false;
        WidthSummary::ExtensionKind OperandExtension =
            WidthSummary::ExtensionKind::Unknown;
        if (inferRequiredBits(I->getOperand(0), OperandBits, OperandInference,
                              OperandExtension, Visited) &&
            OperandBits <= Bits) {
          Bits = OperandBits;
          Extension = OperandExtension;
        }
      }
      UsedInference = true;
      return true;
    case Instruction::ZExt:
      if (!inferRequiredBits(I->getOperand(0), Bits, UsedInference, Extension,
                             Visited))
        return false;
      Extension = WidthSummary::ExtensionKind::Zero;
      UsedInference = true;
      return true;
    case Instruction::SExt:
      if (!I->getOperand(0)->getType()->isIntegerTy())
        return false;
      Bits = cast<IntegerType>(I->getOperand(0)->getType())->getBitWidth();
      Extension = WidthSummary::ExtensionKind::Sign;
      UsedInference = true;
      return true;
    case Instruction::And:
      return inferAndRequiredBits(*I, Bits, UsedInference, Extension);
    case Instruction::Or:
      return inferBinaryMaxBits(*I, Bits, UsedInference, Extension, Visited);
    case Instruction::Select:
      return inferSelectRequiredBits(*cast<SelectInst>(I), Bits, UsedInference,
                                     Extension, Visited);
    case Instruction::PHI:
      return inferPhiRequiredBits(*cast<PHINode>(I), Bits, UsedInference,
                                  Extension, Visited);
    default:
      return inferKnownBitsRequiredBits(*I, Bits, UsedInference, Extension);
    }
  }

  bool inferKnownBitsRequiredBits(Instruction &I, unsigned &Bits,
                                  bool &UsedInference,
                                  WidthSummary::ExtensionKind &Extension) {
    if (!DL || !I.getType()->isIntegerTy())
      return false;

    KnownBits Known = computeKnownBits(&I, *DL, /*Depth=*/0);
    if (Known.hasConflict())
      return false;

    unsigned BitWidth = Known.getBitWidth();
    unsigned LeadingKnownZeros = Known.Zero.countl_one();
    if (LeadingKnownZeros == 0)
      return false;

    Bits = std::max(BitWidth - LeadingKnownZeros, 1u);
    Extension = WidthSummary::ExtensionKind::Zero;
    UsedInference = true;
    return true;
  }

  bool inferAndRequiredBits(Instruction &I, unsigned &Bits,
                            bool &UsedInference,
                            WidthSummary::ExtensionKind &Extension) {
    auto *LHSConst = dyn_cast<ConstantInt>(I.getOperand(0));
    auto *RHSConst = dyn_cast<ConstantInt>(I.getOperand(1));
    ConstantInt *Mask = LHSConst ? LHSConst : RHSConst;
    if (!Mask)
      return false;

    Bits = std::max(Mask->getValue().getActiveBits(), 1u);
    Extension = WidthSummary::ExtensionKind::Zero;
    UsedInference = true;
    return true;
  }

  bool inferBinaryMaxBits(Instruction &I, unsigned &Bits, bool &UsedInference,
                          WidthSummary::ExtensionKind &Extension,
                          SmallPtrSetImpl<Value *> &Visited) {
    unsigned LHSBits = 0;
    unsigned RHSBits = 0;
    bool LHSInference = false;
    bool RHSInference = false;
    WidthSummary::ExtensionKind LHSExt = WidthSummary::ExtensionKind::Unknown;
    WidthSummary::ExtensionKind RHSExt = WidthSummary::ExtensionKind::Unknown;
    if (!inferRequiredBits(I.getOperand(0), LHSBits, LHSInference, LHSExt,
                           Visited) ||
        !inferRequiredBits(I.getOperand(1), RHSBits, RHSInference, RHSExt,
                           Visited) ||
        LHSExt != RHSExt)
      return false;

    Bits = std::max(LHSBits, RHSBits);
    Extension = LHSExt;
    UsedInference = true;
    return true;
  }

  bool inferSelectRequiredBits(SelectInst &SI, unsigned &Bits,
                               bool &UsedInference,
                               WidthSummary::ExtensionKind &Extension,
                               SmallPtrSetImpl<Value *> &Visited) {
    unsigned TrueBits = 0;
    unsigned FalseBits = 0;
    bool TrueInference = false;
    bool FalseInference = false;
    WidthSummary::ExtensionKind TrueExt = WidthSummary::ExtensionKind::Unknown;
    WidthSummary::ExtensionKind FalseExt = WidthSummary::ExtensionKind::Unknown;
    if (!inferRequiredBits(SI.getTrueValue(), TrueBits, TrueInference,
                           TrueExt, Visited) ||
        !inferRequiredBits(SI.getFalseValue(), FalseBits, FalseInference,
                           FalseExt, Visited) ||
        TrueExt != FalseExt)
      return false;

    Bits = std::max(TrueBits, FalseBits);
    Extension = TrueExt;
    UsedInference = true;
    return true;
  }

  bool inferPhiRequiredBits(PHINode &PN, unsigned &Bits, bool &UsedInference,
                            WidthSummary::ExtensionKind &Extension,
                            SmallPtrSetImpl<Value *> &Visited) {
    unsigned MaxBits = 1;
    WidthSummary::ExtensionKind PhiExt = WidthSummary::ExtensionKind::Unknown;
    for (Value *Incoming : PN.incoming_values()) {
      unsigned IncomingBits = 0;
      bool IncomingInference = false;
      WidthSummary::ExtensionKind IncomingExt =
          WidthSummary::ExtensionKind::Unknown;
      if (!inferRequiredBits(Incoming, IncomingBits, IncomingInference,
                             IncomingExt, Visited))
        return false;
      if (PhiExt == WidthSummary::ExtensionKind::Unknown)
        PhiExt = IncomingExt;
      else if (PhiExt != IncomingExt)
        return false;
      MaxBits = std::max(MaxBits, IncomingBits);
    }

    Bits = MaxBits;
    Extension = PhiExt;
    UsedInference = true;
    return true;
  }

  void analyzePointerUsers(Value &Root, Value &Ptr, SafetySummary &Summary,
                           SmallPtrSetImpl<const Value *> &Visited) {
    if (!Visited.insert(&Ptr).second)
      return;

    for (Use &U : Ptr.uses()) {
      User *Usr = U.getUser();

      if (auto *GEP = dyn_cast<GetElementPtrInst>(Usr)) {
        ++Summary.SupportedUses;
        analyzePointerUsers(Root, *GEP, Summary, Visited);
        continue;
      }

      if (auto *LI = dyn_cast<LoadInst>(Usr)) {
        if (LI->getPointerOperand() == &Ptr) {
          if (LI->isVolatile() || LI->isAtomic()) {
            noteUnsupported(Root, *Usr, "volatile-or-atomic-memory", Summary);
            continue;
          }
          ++Summary.SupportedUses;
          ++Summary.LoadUses;
          continue;
        }
      }

      if (auto *SI = dyn_cast<StoreInst>(Usr)) {
        if (SI->getPointerOperand() == &Ptr) {
          if (SI->isVolatile() || SI->isAtomic()) {
            noteUnsupported(Root, *Usr, "volatile-or-atomic-memory", Summary);
            continue;
          }
          ++Summary.SupportedUses;
          ++Summary.StoreUses;
          continue;
        }

        noteUnsupported(Root, *Usr, "pointer-stored-as-value", Summary);
        continue;
      }

      if (auto *BC = dyn_cast<BitCastInst>(Usr)) {
        ++Summary.SupportedUses;
        analyzePointerUsers(Root, *BC, Summary, Visited);
        continue;
      }

      if (auto *ASC = dyn_cast<AddrSpaceCastInst>(Usr)) {
        ++Summary.SupportedUses;
        analyzePointerUsers(Root, *ASC, Summary, Visited);
        continue;
      }

      noteUnsupported(Root, *Usr, "unsupported-user", Summary);
    }
  }

  void noteUnsupported(Value &Root, User &Usr, const char *Reason,
                       SafetySummary &Summary) {
    ++Summary.UnsupportedUses;
    if (!Summary.FirstUnsupportedReason)
      Summary.FirstUnsupportedReason = Reason;

    std::string Message;
    raw_string_ostream OS(Message);
    OS << "[adaptive-width-mem] reject candidate=";
    printValueName(OS, Root);
    OS << " reason=" << Reason << " user=";
    if (auto *I = dyn_cast<Instruction>(&Usr)) {
      OS << I->getOpcodeName();
      if (I->getFunction())
        OS << " function=" << I->getFunction()->getName();
    } else {
      OS << "constant-or-metadata";
    }
    Summary.Rejections.push_back(OS.str());
  }
};

} // namespace

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "AdaptiveWidthMemoryPass",
          LLVM_VERSION_STRING, [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  PassConfig Config;
                  if (Name == "adaptive-width-mem") {
                    Config = PassConfig{};
                  } else if (Name == "adaptive-width-mem-log") {
                    Config.Transform = false;
                    Config.ModeName = "adaptive-width-mem-log";
                  } else if (Name == "adaptive-width-mem-allocas") {
                    Config.ProcessGlobals = false;
                    Config.ModeName = "adaptive-width-mem-allocas";
                  } else if (Name == "adaptive-width-mem-globals") {
                    Config.ProcessAllocas = false;
                    Config.ModeName = "adaptive-width-mem-globals";
                  } else if (Name == "adaptive-width-mem-target-aware") {
                    Config.RequireTargetAllocationBenefit = true;
                    Config.ModeName = "adaptive-width-mem-target-aware";
                  } else {
                    return false;
                  }

                  MPM.addPass(AdaptiveWidthMemoryPass(Config));
                  return true;
                });
          }};
}
