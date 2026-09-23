; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/transformed-ir/grayscale_threshold.out.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/grayscale_threshold.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i32 @grayscale_threshold(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) local_unnamed_addr #0 {
  %.wide11 = lshr i32 %0, 7
  %.wide11.lobit = and i32 %.wide11, 1
  %.wide8 = lshr i32 %1, 7
  %.wide8.lobit = and i32 %.wide8, 1
  %5 = add nuw nsw i32 %.wide8.lobit, %.wide11.lobit
  %.wide5 = lshr i32 %2, 7
  %.wide5.lobit = and i32 %.wide5, 1
  %6 = add nuw nsw i32 %5, %.wide5.lobit
  %.wide = lshr i32 %3, 7
  %.wide.lobit = and i32 %.wide, 1
  %7 = add nuw nsw i32 %6, %.wide.lobit
  ret i32 %7
}

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
