; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/unsigned_histogram.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/unsigned_histogram.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@bins = internal global [4 x i16] [i16 1, i16 3, i16 7, i16 15], align 2
@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @unsigned_histogram(ptr noundef %0, i32 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca [4 x i16], align 2
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 %1, ptr %4, align 4
  %8 = load ptr, ptr %3, align 8
  %9 = getelementptr inbounds i32, ptr %8, i64 0
  %10 = load i32, ptr %9, align 4
  %11 = and i32 %10, 15
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  store i16 %12, ptr %13, align 2
  %14 = load ptr, ptr %3, align 8
  %15 = getelementptr inbounds i32, ptr %14, i64 1
  %16 = load i32, ptr %15, align 4
  %17 = and i32 %16, 31
  %18 = trunc i32 %17 to i16
  %19 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  store i16 %18, ptr %19, align 2
  %20 = load ptr, ptr %3, align 8
  %21 = getelementptr inbounds i32, ptr %20, i64 2
  %22 = load i32, ptr %21, align 4
  %23 = and i32 %22, 63
  %24 = trunc i32 %23 to i16
  %25 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  store i16 %24, ptr %25, align 2
  %26 = load ptr, ptr %3, align 8
  %27 = getelementptr inbounds i32, ptr %26, i64 3
  %28 = load i32, ptr %27, align 4
  %29 = and i32 %28, 127
  %30 = trunc i32 %29 to i16
  %31 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  store i16 %30, ptr %31, align 2
  store i32 0, ptr %6, align 4
  store i32 0, ptr %7, align 4
  br label %32

32:                                               ; preds = %55, %2
  %33 = load i32, ptr %7, align 4
  %34 = icmp ult i32 %33, 4
  br i1 %34, label %35, label %39

35:                                               ; preds = %32
  %36 = load i32, ptr %7, align 4
  %37 = load i32, ptr %4, align 4
  %38 = icmp ult i32 %36, %37
  br label %39

39:                                               ; preds = %35, %32
  %40 = phi i1 [ false, %32 ], [ %38, %35 ]
  br i1 %40, label %41, label %58

41:                                               ; preds = %39
  %42 = load i32, ptr %7, align 4
  %43 = zext i32 %42 to i64
  %44 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 %43
  %45 = load i16, ptr %44, align 2
  %46 = zext i16 %45 to i32
  %47 = load i32, ptr %7, align 4
  %48 = zext i32 %47 to i64
  %49 = getelementptr inbounds [4 x i16], ptr @bins, i64 0, i64 %48
  %50 = load i16, ptr %49, align 2
  %51 = zext i16 %50 to i32
  %52 = add nsw i32 %46, %51
  %53 = load i32, ptr %6, align 4
  %54 = add i32 %53, %52
  store i32 %54, ptr %6, align 4
  br label %55

55:                                               ; preds = %41
  %56 = load i32, ptr %7, align 4
  %57 = add i32 %56, 1
  store i32 %57, ptr %7, align 4
  br label %32, !llvm.loop !6

58:                                               ; preds = %39
  %59 = load i32, ptr %6, align 4
  ret i32 %59
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca [4 x i32], align 16
  %4 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 0, ptr %4, align 4
  br label %5

5:                                                ; preds = %29, %0
  %6 = load i32, ptr %4, align 4
  %7 = icmp ult i32 %6, 128
  br i1 %7, label %8, label %32

8:                                                ; preds = %5
  %9 = load i32, ptr %4, align 4
  %10 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 0
  store i32 %9, ptr %10, align 16
  %11 = load i32, ptr %4, align 4
  %12 = mul i32 %11, 3
  %13 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 1
  store i32 %12, ptr %13, align 4
  %14 = load i32, ptr %4, align 4
  %15 = mul i32 %14, 5
  %16 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 2
  store i32 %15, ptr %16, align 8
  %17 = load i32, ptr %4, align 4
  %18 = mul i32 %17, 7
  %19 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 3
  store i32 %18, ptr %19, align 4
  br label %20

20:                                               ; preds = %8
  %21 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 0
  %22 = call i32 @unsigned_histogram(ptr noundef %21, i32 noundef 4)
  %23 = zext i32 %22 to i64
  %24 = load i64, ptr %2, align 8
  %25 = xor i64 %24, %23
  store i64 %25, ptr %2, align 8
  %26 = load i64, ptr %2, align 8
  %27 = mul i64 %26, 1099511628211
  store i64 %27, ptr %2, align 8
  br label %28

28:                                               ; preds = %20
  br label %29

29:                                               ; preds = %28
  %30 = load i32, ptr %4, align 4
  %31 = add i32 %30, 13
  store i32 %31, ptr %4, align 4
  br label %5, !llvm.loop !8

32:                                               ; preds = %5
  %33 = load i64, ptr %2, align 8
  %34 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %33)
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
