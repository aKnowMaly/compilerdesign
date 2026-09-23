; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/signed_delta_pair.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/signed_delta_pair.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_delta_pair(i8 noundef signext %0, i8 noundef signext %1) #0 {
  %3 = alloca i8, align 1
  %4 = alloca i8, align 1
  %5 = alloca [2 x i16], align 2
  store i8 %0, ptr %3, align 1
  store i8 %1, ptr %4, align 1
  %6 = load i8, ptr %3, align 1
  %7 = sext i8 %6 to i16
  %8 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 0
  store i16 %7, ptr %8, align 2
  %9 = load i8, ptr %4, align 1
  %10 = sext i8 %9 to i16
  %11 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 1
  store i16 %10, ptr %11, align 2
  %12 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 0
  %13 = load i16, ptr %12, align 2
  %14 = sext i16 %13 to i32
  %15 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 1
  %16 = load i16, ptr %15, align 2
  %17 = sext i16 %16 to i32
  %18 = sub nsw i32 %14, %17
  %19 = trunc i32 %18 to i16
  ret i16 %19
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 -96, ptr %3, align 4
  br label %5

5:                                                ; preds = %30, %0
  %6 = load i32, ptr %3, align 4
  %7 = icmp sle i32 %6, 96
  br i1 %7, label %8, label %33

8:                                                ; preds = %5
  store i32 -80, ptr %4, align 4
  br label %9

9:                                                ; preds = %26, %8
  %10 = load i32, ptr %4, align 4
  %11 = icmp sle i32 %10, 80
  br i1 %11, label %12, label %29

12:                                               ; preds = %9
  br label %13

13:                                               ; preds = %12
  %14 = load i32, ptr %3, align 4
  %15 = trunc i32 %14 to i8
  %16 = load i32, ptr %4, align 4
  %17 = trunc i32 %16 to i8
  %18 = call signext i16 @signed_delta_pair(i8 noundef signext %15, i8 noundef signext %17)
  %19 = sext i16 %18 to i32
  %20 = zext i32 %19 to i64
  %21 = load i64, ptr %2, align 8
  %22 = xor i64 %21, %20
  store i64 %22, ptr %2, align 8
  %23 = load i64, ptr %2, align 8
  %24 = mul i64 %23, 1099511628211
  store i64 %24, ptr %2, align 8
  br label %25

25:                                               ; preds = %13
  br label %26

26:                                               ; preds = %25
  %27 = load i32, ptr %4, align 4
  %28 = add nsw i32 %27, 29
  store i32 %28, ptr %4, align 4
  br label %9, !llvm.loop !6

29:                                               ; preds = %9
  br label %30

30:                                               ; preds = %29
  %31 = load i32, ptr %3, align 4
  %32 = add nsw i32 %31, 31
  store i32 %32, ptr %3, align 4
  br label %5, !llvm.loop !8

33:                                               ; preds = %5
  %34 = load i64, ptr %2, align 8
  %35 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %34)
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
