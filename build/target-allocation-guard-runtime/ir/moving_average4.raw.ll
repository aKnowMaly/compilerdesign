; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/moving_average4.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/moving_average4.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @moving_average4(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) #0 {
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
  %11 = and i32 %10, 1023
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 0
  store i16 %12, ptr %13, align 2
  %14 = load i32, ptr %6, align 4
  %15 = and i32 %14, 1023
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 1
  store i16 %16, ptr %17, align 2
  %18 = load i32, ptr %7, align 4
  %19 = and i32 %18, 1023
  %20 = trunc i32 %19 to i16
  %21 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 2
  store i16 %20, ptr %21, align 2
  %22 = load i32, ptr %8, align 4
  %23 = and i32 %22, 1023
  %24 = trunc i32 %23 to i16
  %25 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 3
  store i16 %24, ptr %25, align 2
  %26 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 0
  %27 = load i16, ptr %26, align 2
  %28 = zext i16 %27 to i32
  %29 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 1
  %30 = load i16, ptr %29, align 2
  %31 = zext i16 %30 to i32
  %32 = add nsw i32 %28, %31
  %33 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 2
  %34 = load i16, ptr %33, align 2
  %35 = zext i16 %34 to i32
  %36 = add nsw i32 %32, %35
  %37 = getelementptr inbounds [4 x i16], ptr %9, i64 0, i64 3
  %38 = load i16, ptr %37, align 2
  %39 = zext i16 %38 to i32
  %40 = add nsw i32 %36, %39
  %41 = ashr i32 %40, 2
  ret i32 %41
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 0, ptr %3, align 4
  br label %4

4:                                                ; preds = %23, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 128
  br i1 %6, label %7, label %26

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = load i32, ptr %3, align 4
  %11 = mul i32 %10, 3
  %12 = load i32, ptr %3, align 4
  %13 = mul i32 %12, 5
  %14 = load i32, ptr %3, align 4
  %15 = mul i32 %14, 7
  %16 = call i32 @moving_average4(i32 noundef %9, i32 noundef %11, i32 noundef %13, i32 noundef %15)
  %17 = zext i32 %16 to i64
  %18 = load i64, ptr %2, align 8
  %19 = xor i64 %18, %17
  store i64 %19, ptr %2, align 8
  %20 = load i64, ptr %2, align 8
  %21 = mul i64 %20, 1099511628211
  store i64 %21, ptr %2, align 8
  br label %22

22:                                               ; preds = %8
  br label %23

23:                                               ; preds = %22
  %24 = load i32, ptr %3, align 4
  %25 = add i32 %24, 7
  store i32 %25, ptr %3, align 4
  br label %4, !llvm.loop !6

26:                                               ; preds = %4
  %27 = load i64, ptr %2, align 8
  %28 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %27)
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

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
