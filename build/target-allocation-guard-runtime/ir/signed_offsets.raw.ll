; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/signed_offsets.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/signed_offsets.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_offsets(i8 noundef signext %0, i8 noundef signext %1, i32 noundef %2) #0 {
  %4 = alloca i8, align 1
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca [2 x i16], align 2
  %8 = alloca i16, align 2
  %9 = alloca i16, align 2
  store i8 %0, ptr %4, align 1
  store i8 %1, ptr %5, align 1
  store i32 %2, ptr %6, align 4
  %10 = load i8, ptr %4, align 1
  %11 = sext i8 %10 to i16
  store i16 %11, ptr %8, align 2
  %12 = load i8, ptr %5, align 1
  %13 = sext i8 %12 to i16
  store i16 %13, ptr %9, align 2
  %14 = load i16, ptr %8, align 2
  %15 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 0
  store i16 %14, ptr %15, align 2
  %16 = load i16, ptr %9, align 2
  %17 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 1
  store i16 %16, ptr %17, align 2
  %18 = load i32, ptr %6, align 4
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %20, label %24

20:                                               ; preds = %3
  %21 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 0
  %22 = load i16, ptr %21, align 2
  %23 = sext i16 %22 to i32
  br label %28

24:                                               ; preds = %3
  %25 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 1
  %26 = load i16, ptr %25, align 2
  %27 = sext i16 %26 to i32
  br label %28

28:                                               ; preds = %24, %20
  %29 = phi i32 [ %23, %20 ], [ %27, %24 ]
  %30 = trunc i32 %29 to i16
  ret i16 %30
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 -96, ptr %3, align 4
  br label %6

6:                                                ; preds = %40, %0
  %7 = load i32, ptr %3, align 4
  %8 = icmp sle i32 %7, 96
  br i1 %8, label %9, label %43

9:                                                ; preds = %6
  store i32 -80, ptr %4, align 4
  br label %10

10:                                               ; preds = %36, %9
  %11 = load i32, ptr %4, align 4
  %12 = icmp sle i32 %11, 80
  br i1 %12, label %13, label %39

13:                                               ; preds = %10
  store i32 0, ptr %5, align 4
  br label %14

14:                                               ; preds = %32, %13
  %15 = load i32, ptr %5, align 4
  %16 = icmp slt i32 %15, 2
  br i1 %16, label %17, label %35

17:                                               ; preds = %14
  br label %18

18:                                               ; preds = %17
  %19 = load i32, ptr %3, align 4
  %20 = trunc i32 %19 to i8
  %21 = load i32, ptr %4, align 4
  %22 = trunc i32 %21 to i8
  %23 = load i32, ptr %5, align 4
  %24 = call signext i16 @signed_offsets(i8 noundef signext %20, i8 noundef signext %22, i32 noundef %23)
  %25 = sext i16 %24 to i32
  %26 = zext i32 %25 to i64
  %27 = load i64, ptr %2, align 8
  %28 = xor i64 %27, %26
  store i64 %28, ptr %2, align 8
  %29 = load i64, ptr %2, align 8
  %30 = mul i64 %29, 1099511628211
  store i64 %30, ptr %2, align 8
  br label %31

31:                                               ; preds = %18
  br label %32

32:                                               ; preds = %31
  %33 = load i32, ptr %5, align 4
  %34 = add nsw i32 %33, 1
  store i32 %34, ptr %5, align 4
  br label %14, !llvm.loop !6

35:                                               ; preds = %14
  br label %36

36:                                               ; preds = %35
  %37 = load i32, ptr %4, align 4
  %38 = add nsw i32 %37, 29
  store i32 %38, ptr %4, align 4
  br label %10, !llvm.loop !8

39:                                               ; preds = %10
  br label %40

40:                                               ; preds = %39
  %41 = load i32, ptr %3, align 4
  %42 = add nsw i32 %41, 31
  store i32 %42, ptr %3, align 4
  br label %6, !llvm.loop !9

43:                                               ; preds = %6
  %44 = load i64, ptr %2, align 8
  %45 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %44)
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
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
