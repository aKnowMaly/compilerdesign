; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/global_constants.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/global_constants.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@lut_a = internal global i16 5, align 2
@lut_b = internal global i16 12, align 2
@lut_c = internal global [2 x i16] [i16 3, i16 9], align 2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @global_constants() #0 {
  %1 = load i16, ptr @lut_a, align 2
  %2 = zext i16 %1 to i32
  %3 = load i16, ptr @lut_b, align 2
  %4 = zext i16 %3 to i32
  %5 = add nsw i32 %2, %4
  %6 = load i16, ptr @lut_c, align 2
  %7 = zext i16 %6 to i32
  %8 = add nsw i32 %5, %7
  %9 = load i16, ptr getelementptr inbounds ([2 x i16], ptr @lut_c, i64 0, i64 1), align 2
  %10 = zext i16 %9 to i32
  %11 = add nsw i32 %8, %10
  ret i32 %11
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
