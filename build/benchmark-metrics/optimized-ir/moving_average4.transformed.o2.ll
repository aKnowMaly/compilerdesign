; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/transformed-ir/moving_average4.out.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/moving_average4.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i32 @moving_average4(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) local_unnamed_addr #0 {
  %.wide11 = and i32 %0, 1023
  %.wide8 = and i32 %1, 1023
  %5 = add nuw nsw i32 %.wide8, %.wide11
  %.wide5 = and i32 %2, 1023
  %6 = add nuw nsw i32 %5, %.wide5
  %.wide = and i32 %3, 1023
  %7 = add nuw nsw i32 %6, %.wide
  %8 = lshr i32 %7, 2
  ret i32 %8
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
