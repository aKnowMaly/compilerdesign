; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/alias_pointer_reject.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/alias_pointer_reject.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local i32 @alias_pointer_reject(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = alloca [2 x i16], align 2
  %.not = icmp ne i32 %1, 0
  %4 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %5 = select i1 %.not, ptr %4, ptr %3
  %6 = trunc i32 %0 to i16
  %7 = and i16 %6, 31
  store i16 %7, ptr %5, align 2
  %8 = zext i1 %.not to i64
  %9 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 %8
  %10 = load i16, ptr %9, align 2
  %11 = zext i16 %10 to i32
  ret i32 %11
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
