; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/transformed-ir/unsigned_histogram.out.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/unsigned_histogram.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree noinline norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local i32 @unsigned_histogram(ptr nocapture noundef readonly %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = load i32, ptr %0, align 4
  %.narrow10 = and i32 %3, 15
  %4 = getelementptr inbounds i32, ptr %0, i64 1
  %5 = load i32, ptr %4, align 4
  %.narrow8 = and i32 %5, 31
  %6 = getelementptr inbounds i32, ptr %0, i64 2
  %7 = load i32, ptr %6, align 4
  %.narrow6 = and i32 %7, 63
  %8 = getelementptr inbounds i32, ptr %0, i64 3
  %9 = load i32, ptr %8, align 4
  %spec.select1.not = icmp eq i32 %1, 0
  br i1 %spec.select1.not, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %2
  %10 = add nuw nsw i32 %.narrow10, 1
  %exitcond.not = icmp eq i32 %1, 1
  br i1 %exitcond.not, label %._crit_edge, label %.lr.ph.1, !llvm.loop !6

.lr.ph.1:                                         ; preds = %.lr.ph
  %11 = add nuw nsw i32 %10, %.narrow8
  %12 = add nuw nsw i32 %11, 3
  %exitcond.not.1 = icmp eq i32 %1, 2
  br i1 %exitcond.not.1, label %._crit_edge, label %.lr.ph.2, !llvm.loop !6

.lr.ph.2:                                         ; preds = %.lr.ph.1
  %13 = add nuw nsw i32 %12, %.narrow6
  %14 = add nuw nsw i32 %13, 7
  %exitcond.not.2 = icmp eq i32 %1, 3
  br i1 %exitcond.not.2, label %._crit_edge, label %.lr.ph.3, !llvm.loop !6

.lr.ph.3:                                         ; preds = %.lr.ph.2
  %15 = and i32 %9, 127
  %16 = add nuw nsw i32 %14, %15
  %17 = add i32 %16, 15
  br label %._crit_edge

._crit_edge:                                      ; preds = %.lr.ph, %.lr.ph.1, %.lr.ph.2, %.lr.ph.3, %2
  %.01.lcssa = phi i32 [ 0, %2 ], [ %10, %.lr.ph ], [ %12, %.lr.ph.1 ], [ %14, %.lr.ph.2 ], [ %17, %.lr.ph.3 ]
  ret i32 %.01.lcssa
}

attributes #0 = { nofree noinline norecurse nosync nounwind memory(argmem: read) uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
