; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/embedded_counters.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/embedded_counters.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @embedded_counters(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [4 x i16], align 2
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = and i32 %4, 15
  %6 = trunc i32 %5 to i16
  %7 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  store i16 %6, ptr %7, align 2
  %8 = load i32, ptr %2, align 4
  %9 = lshr i32 %8, 4
  %10 = and i32 %9, 15
  %11 = trunc i32 %10 to i16
  %12 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  store i16 %11, ptr %12, align 2
  %13 = load i32, ptr %2, align 4
  %14 = lshr i32 %13, 8
  %15 = and i32 %14, 15
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  store i16 %16, ptr %17, align 2
  %18 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  %19 = load i16, ptr %18, align 2
  %20 = zext i16 %19 to i32
  %21 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  %22 = load i16, ptr %21, align 2
  %23 = zext i16 %22 to i32
  %24 = add nsw i32 %20, %23
  %25 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  %26 = load i16, ptr %25, align 2
  %27 = zext i16 %26 to i32
  %28 = add nsw i32 %24, %27
  %29 = and i32 %28, 31
  %30 = trunc i32 %29 to i16
  %31 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  store i16 %30, ptr %31, align 2
  %32 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  %33 = load i16, ptr %32, align 2
  %34 = zext i16 %33 to i32
  ret i32 %34
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
