; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/alpha_blend_weights.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/alpha_blend_weights.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @alpha_blend_weights(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca [3 x i16], align 2
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  store i32 %2, ptr %6, align 4
  %8 = load i32, ptr %4, align 4
  %9 = and i32 %8, 255
  %10 = trunc i32 %9 to i16
  %11 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 0
  store i16 %10, ptr %11, align 2
  %12 = load i32, ptr %5, align 4
  %13 = and i32 %12, 255
  %14 = trunc i32 %13 to i16
  %15 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 1
  store i16 %14, ptr %15, align 2
  %16 = load i32, ptr %6, align 4
  %17 = and i32 %16, 255
  %18 = trunc i32 %17 to i16
  %19 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 2
  store i16 %18, ptr %19, align 2
  %20 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 0
  %21 = load i16, ptr %20, align 2
  %22 = zext i16 %21 to i32
  %23 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 1
  %24 = load i16, ptr %23, align 2
  %25 = zext i16 %24 to i32
  %26 = mul nsw i32 %22, %25
  %27 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 0
  %28 = load i16, ptr %27, align 2
  %29 = zext i16 %28 to i32
  %30 = sub i32 255, %29
  %31 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 2
  %32 = load i16, ptr %31, align 2
  %33 = zext i16 %32 to i32
  %34 = mul i32 %30, %33
  %35 = add i32 %26, %34
  %36 = lshr i32 %35, 8
  ret i32 %36
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

4:                                                ; preds = %22, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 128
  br i1 %6, label %7, label %25

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = mul i32 %9, 3
  %11 = load i32, ptr %3, align 4
  %12 = mul i32 %11, 17
  %13 = load i32, ptr %3, align 4
  %14 = mul i32 %13, 29
  %15 = call i32 @alpha_blend_weights(i32 noundef %10, i32 noundef %12, i32 noundef %14)
  %16 = zext i32 %15 to i64
  %17 = load i64, ptr %2, align 8
  %18 = xor i64 %17, %16
  store i64 %18, ptr %2, align 8
  %19 = load i64, ptr %2, align 8
  %20 = mul i64 %19, 1099511628211
  store i64 %20, ptr %2, align 8
  br label %21

21:                                               ; preds = %8
  br label %22

22:                                               ; preds = %21
  %23 = load i32, ptr %3, align 4
  %24 = add i32 %23, 5
  store i32 %24, ptr %3, align 4
  br label %4, !llvm.loop !6

25:                                               ; preds = %4
  %26 = load i64, ptr %2, align 8
  %27 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %26)
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
