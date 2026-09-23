; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/embedded_counters.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/embedded_counters.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @embedded_counters(i32 noundef %0) #0 {
  %2 = alloca [4 x i16], align 2
  %3 = and i32 %0, 15
  %4 = trunc i32 %3 to i16
  %5 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 0
  store i16 %4, ptr %5, align 2
  %6 = lshr i32 %0, 4
  %7 = and i32 %6, 15
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 1
  store i16 %8, ptr %9, align 2
  %10 = lshr i32 %0, 8
  %11 = and i32 %10, 15
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 2
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 0
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 1
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  %20 = add nsw i32 %16, %19
  %21 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 2
  %22 = load i16, ptr %21, align 2
  %23 = zext i16 %22 to i32
  %24 = add nsw i32 %20, %23
  %25 = and i32 %24, 31
  %26 = trunc i32 %25 to i16
  %27 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 3
  store i16 %26, ptr %27, align 2
  %28 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 3
  %29 = load i16, ptr %28, align 2
  %30 = zext i16 %29 to i32
  ret i32 %30
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
