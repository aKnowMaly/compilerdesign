; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/transformed-ir/tcp_flag_decode.out.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/tcp_flag_decode.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i32 @tcp_flag_decode(i32 noundef %0) local_unnamed_addr #0 {
  %2 = and i32 %0, 3
  %3 = and i32 %0, 4
  %.not = icmp eq i32 %3, 0
  %4 = select i1 %.not, i32 0, i32 3
  %5 = lshr i32 %0, 1
  %6 = and i32 %5, 4
  %7 = and i32 %0, 16
  %.not1 = icmp eq i32 %7, 0
  %8 = select i1 %.not1, i32 0, i32 5
  %9 = and i32 %0, 32
  %.not2 = icmp eq i32 %9, 0
  %10 = select i1 %.not2, i32 0, i32 6
  %11 = or disjoint i32 %6, %2
  %12 = add nuw nsw i32 %11, %4
  %13 = add nuw nsw i32 %12, %8
  %14 = add nuw nsw i32 %13, %10
  ret i32 %14
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
