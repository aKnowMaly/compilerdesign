; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/grayscale_threshold.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/grayscale_threshold.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @grayscale_threshold(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca [4 x i16], align 2
  store i32 %0, ptr %5, align 4
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  store i32 %3, ptr %8, align 4
  %10 = load i32, ptr %5, align 4
  %11 = and i32 %10, 255
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 0
  store i16 %12, ptr %13, align 2
  %14 = load i32, ptr %6, align 4
  %15 = and i32 %14, 255
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 1
  store i16 %16, ptr %17, align 2
  %18 = load i32, ptr %7, align 4
  %19 = and i32 %18, 255
  %20 = trunc i32 %19 to i16
  %21 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 2
  store i16 %20, ptr %21, align 2
  %22 = load i32, ptr %8, align 4
  %23 = and i32 %22, 255
  %24 = trunc i32 %23 to i16
  %25 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 3
  store i16 %24, ptr %25, align 2
  %26 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 0
  %27 = load i16, ptr %26, align 2
  %28 = zext i16 %27 to i32
  %29 = icmp ugt i32 %28, 127
  %30 = zext i1 %29 to i32
  %31 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 1
  %32 = load i16, ptr %31, align 2
  %33 = zext i16 %32 to i32
  %34 = icmp ugt i32 %33, 127
  %35 = zext i1 %34 to i32
  %36 = add nsw i32 %30, %35
  %37 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 2
  %38 = load i16, ptr %37, align 2
  %39 = zext i16 %38 to i32
  %40 = icmp ugt i32 %39, 127
  %41 = zext i1 %40 to i32
  %42 = add nsw i32 %36, %41
  %43 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 3
  %44 = load i16, ptr %43, align 2
  %45 = zext i16 %44 to i32
  %46 = icmp ugt i32 %45, 127
  %47 = zext i1 %46 to i32
  %48 = add nsw i32 %42, %47
  ret i32 %48
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
