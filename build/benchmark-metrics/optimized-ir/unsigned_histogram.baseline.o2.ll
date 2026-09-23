; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/unsigned_histogram.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/unsigned_histogram.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree noinline norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local i32 @unsigned_histogram(ptr nocapture noundef readonly %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = load <4 x i32>, ptr %0, align 4
  %4 = trunc <4 x i32> %3 to <4 x i16>
  %5 = and <4 x i16> %4, <i16 15, i16 31, i16 63, i16 127>
  %spec.select1.not = icmp eq i32 %1, 0
  br i1 %spec.select1.not, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %2
  %.sroa.0.0.vec.extract = extractelement <4 x i16> %5, i64 0
  %narrow = add nuw nsw i16 %.sroa.0.0.vec.extract, 1
  %6 = zext nneg i16 %narrow to i32
  %exitcond.not = icmp eq i32 %1, 1
  br i1 %exitcond.not, label %._crit_edge, label %.lr.ph.1, !llvm.loop !6

.lr.ph.1:                                         ; preds = %.lr.ph
  %.sroa.0.2.vec.extract = extractelement <4 x i16> %5, i64 1
  %narrow5 = add nuw nsw i16 %narrow, %.sroa.0.2.vec.extract
  %narrow6 = add nuw nsw i16 %narrow5, 3
  %7 = zext nneg i16 %narrow6 to i32
  %exitcond.not.1 = icmp eq i32 %1, 2
  br i1 %exitcond.not.1, label %._crit_edge, label %.lr.ph.2, !llvm.loop !6

.lr.ph.2:                                         ; preds = %.lr.ph.1
  %.sroa.0.4.vec.extract = extractelement <4 x i16> %5, i64 2
  %narrow7 = add nuw nsw i16 %narrow6, %.sroa.0.4.vec.extract
  %narrow8 = add nuw nsw i16 %narrow7, 7
  %8 = zext i16 %narrow8 to i32
  %exitcond.not.2 = icmp eq i32 %1, 3
  br i1 %exitcond.not.2, label %._crit_edge, label %.lr.ph.3, !llvm.loop !6

.lr.ph.3:                                         ; preds = %.lr.ph.2
  %.sroa.0.6.vec.extract = extractelement <4 x i16> %5, i64 3
  %9 = zext nneg i16 %.sroa.0.6.vec.extract to i32
  %10 = add nuw nsw i32 %8, %9
  %11 = add nuw nsw i32 %10, 15
  br label %._crit_edge

._crit_edge:                                      ; preds = %.lr.ph, %.lr.ph.1, %.lr.ph.2, %.lr.ph.3, %2
  %.01.lcssa = phi i32 [ 0, %2 ], [ %6, %.lr.ph ], [ %7, %.lr.ph.1 ], [ %8, %.lr.ph.2 ], [ %11, %.lr.ph.3 ]
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
