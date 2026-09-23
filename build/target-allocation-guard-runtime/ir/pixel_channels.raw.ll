; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/pixel_channels.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/pixel_channels.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @pixel_channels(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [4 x i16], align 2
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = and i32 %4, 255
  %6 = trunc i32 %5 to i16
  %7 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  store i16 %6, ptr %7, align 2
  %8 = load i32, ptr %2, align 4
  %9 = lshr i32 %8, 8
  %10 = and i32 %9, 255
  %11 = trunc i32 %10 to i16
  %12 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  store i16 %11, ptr %12, align 2
  %13 = load i32, ptr %2, align 4
  %14 = lshr i32 %13, 16
  %15 = and i32 %14, 255
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  store i16 %16, ptr %17, align 2
  %18 = load i32, ptr %2, align 4
  %19 = lshr i32 %18, 24
  %20 = and i32 %19, 255
  %21 = trunc i32 %20 to i16
  %22 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  store i16 %21, ptr %22, align 2
  %23 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  %24 = load i16, ptr %23, align 2
  %25 = zext i16 %24 to i32
  %26 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  %27 = load i16, ptr %26, align 2
  %28 = zext i16 %27 to i32
  %29 = add nsw i32 %25, %28
  %30 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  %31 = load i16, ptr %30, align 2
  %32 = zext i16 %31 to i32
  %33 = add nsw i32 %29, %32
  %34 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  %35 = load i16, ptr %34, align 2
  %36 = zext i16 %35 to i32
  %37 = add nsw i32 %33, %36
  ret i32 %37
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
  %10 = mul i32 %9, 65793
  %11 = add i32 %10, -2143281136
  %12 = call i32 @pixel_channels(i32 noundef %11)
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
  %21 = add i32 %20, 5
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
