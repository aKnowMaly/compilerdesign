; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/overflow_uncertainty.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/overflow_uncertainty.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @overflow_uncertainty(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca [2 x i16], align 2
  %4 = and i32 %0, 255
  %5 = trunc i32 %4 to i16
  %6 = and i32 %1, 255
  %7 = trunc i32 %6 to i16
  %8 = zext i16 %5 to i32
  %9 = zext i16 %7 to i32
  %10 = add nsw i32 %8, %9
  %11 = trunc i32 %10 to i16
  %12 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store i16 %11, ptr %12, align 2
  %13 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %14 = load i16, ptr %13, align 2
  %15 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  store i16 %14, ptr %15, align 2
  %16 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %17 = load i16, ptr %16, align 2
  %18 = zext i16 %17 to i32
  ret i32 %18
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
