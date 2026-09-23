; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/transformed-ir/volatile_reject.out.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/volatile_reject.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree noinline norecurse nounwind memory(inaccessiblemem: readwrite) uwtable
define dso_local i32 @volatile_reject(i32 noundef %0) local_unnamed_addr #0 {
  %.sroa.0 = alloca i16, align 2
  %.sroa.2 = alloca i16, align 2
  %2 = trunc i32 %0 to i16
  %3 = and i16 %2, 31
  store volatile i16 %3, ptr %.sroa.0, align 2
  %.sroa.0.0..sroa.0.0..sroa.0.0..sroa.0.0..sroa.0.0. = load volatile i16, ptr %.sroa.0, align 2
  store volatile i16 %.sroa.0.0..sroa.0.0..sroa.0.0..sroa.0.0..sroa.0.0., ptr %.sroa.2, align 2
  %.sroa.2.0..sroa.2.0..sroa.2.0..sroa.2.0..sroa.2.2. = load volatile i16, ptr %.sroa.2, align 2
  %4 = zext i16 %.sroa.2.0..sroa.2.0..sroa.2.0..sroa.2.0..sroa.2.2. to i32
  ret i32 %4
}

attributes #0 = { nofree noinline norecurse nounwind memory(inaccessiblemem: readwrite) uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
