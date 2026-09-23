; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/rejection_cases.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/rejection_cases.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @rejection_cases(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [2 x i16], align 2
  %4 = alloca [2 x i16], align 2
  %5 = alloca [2 x i16], align 2
  %6 = alloca i16, align 2
  %7 = alloca i8, align 1
  %8 = alloca i8, align 1
  store i32 %0, ptr %2, align 4
  %9 = load i32, ptr %2, align 4
  %10 = and i32 %9, 31
  %11 = trunc i32 %10 to i16
  store i16 %11, ptr %6, align 2
  %12 = load i32, ptr %2, align 4
  %13 = trunc i32 %12 to i8
  store i8 %13, ptr %7, align 1
  %14 = load i32, ptr %2, align 4
  %15 = trunc i32 %14 to i8
  store i8 %15, ptr %8, align 1
  %16 = load i16, ptr %6, align 2
  %17 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store i16 %16, ptr %17, align 2
  %18 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  call void @escape_short_array(ptr noundef %18)
  %19 = load i32, ptr %2, align 4
  %20 = add i32 %19, 257
  %21 = trunc i32 %20 to i16
  %22 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  store i16 %21, ptr %22, align 2
  %23 = load i32, ptr %2, align 4
  %24 = and i32 %23, 1
  %25 = icmp ne i32 %24, 0
  br i1 %25, label %26, label %30

26:                                               ; preds = %1
  %27 = load i8, ptr %7, align 1
  %28 = sext i8 %27 to i16
  %29 = sext i16 %28 to i32
  br label %34

30:                                               ; preds = %1
  %31 = load i8, ptr %8, align 1
  %32 = zext i8 %31 to i16
  %33 = zext i16 %32 to i32
  br label %34

34:                                               ; preds = %30, %26
  %35 = phi i32 [ %29, %26 ], [ %33, %30 ]
  %36 = trunc i32 %35 to i16
  %37 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 0
  store i16 %36, ptr %37, align 2
  %38 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %39 = load i16, ptr %38, align 2
  %40 = zext i16 %39 to i32
  %41 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  %42 = load i16, ptr %41, align 2
  %43 = zext i16 %42 to i32
  %44 = add nsw i32 %40, %43
  %45 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 0
  %46 = load i16, ptr %45, align 2
  %47 = zext i16 %46 to i32
  %48 = add nsw i32 %44, %47
  ret i32 %48
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @escape_short_array(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = icmp ne ptr %3, null
  br i1 %4, label %5, label %14

5:                                                ; preds = %1
  %6 = load ptr, ptr %2, align 8
  %7 = getelementptr inbounds i16, ptr %6, i64 0
  %8 = load i16, ptr %7, align 2
  %9 = zext i16 %8 to i32
  %10 = xor i32 %9, 3
  %11 = trunc i32 %10 to i16
  %12 = load ptr, ptr %2, align 8
  %13 = getelementptr inbounds i16, ptr %12, i64 1
  store i16 %11, ptr %13, align 2
  br label %14

14:                                               ; preds = %5, %1
  ret void
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

4:                                                ; preds = %19, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 128
  br i1 %6, label %7, label %22

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = mul i32 %9, 37
  %11 = add i32 %10, 11
  %12 = call i32 @rejection_cases(i32 noundef %11)
  %13 = zext i32 %12 to i64
  %14 = load i64, ptr %2, align 8
  %15 = xor i64 %14, %13
  store i64 %15, ptr %2, align 8
  %16 = load i64, ptr %2, align 8
  %17 = mul i64 %16, 1099511628211
  store i64 %17, ptr %2, align 8
  br label %18

18:                                               ; preds = %8
  br label %19

19:                                               ; preds = %18
  %20 = load i32, ptr %3, align 4
  %21 = add i32 %20, 9
  store i32 %21, ptr %3, align 4
  br label %4, !llvm.loop !6

22:                                               ; preds = %4
  %23 = load i64, ptr %2, align 8
  %24 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %23)
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
