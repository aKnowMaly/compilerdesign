; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/saturating_sensor.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/saturating_sensor.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @saturating_sensor(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [2 x i16], align 2
  %4 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %5 = load i32, ptr %2, align 4
  %6 = and i32 %5, 511
  store i32 %6, ptr %4, align 4
  %7 = load i32, ptr %4, align 4
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store i16 %8, ptr %9, align 2
  %10 = load i32, ptr %4, align 4
  %11 = icmp ugt i32 %10, 255
  br i1 %11, label %12, label %13

12:                                               ; preds = %1
  br label %15

13:                                               ; preds = %1
  %14 = load i32, ptr %4, align 4
  br label %15

15:                                               ; preds = %13, %12
  %16 = phi i32 [ 255, %12 ], [ %14, %13 ]
  %17 = trunc i32 %16 to i16
  %18 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  store i16 %17, ptr %18, align 2
  %19 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %20 = load i16, ptr %19, align 2
  %21 = zext i16 %20 to i32
  %22 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %23 = load i16, ptr %22, align 2
  %24 = zext i16 %23 to i32
  %25 = add nsw i32 %21, %24
  ret i32 %25
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

4:                                                ; preds = %18, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 1024
  br i1 %6, label %7, label %21

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = mul i32 %9, 13
  %11 = call i32 @saturating_sensor(i32 noundef %10)
  %12 = zext i32 %11 to i64
  %13 = load i64, ptr %2, align 8
  %14 = xor i64 %13, %12
  store i64 %14, ptr %2, align 8
  %15 = load i64, ptr %2, align 8
  %16 = mul i64 %15, 1099511628211
  store i64 %16, ptr %2, align 8
  br label %17

17:                                               ; preds = %8
  br label %18

18:                                               ; preds = %17
  %19 = load i32, ptr %3, align 4
  %20 = add i32 %19, 37
  store i32 %20, ptr %3, align 4
  br label %4, !llvm.loop !6

21:                                               ; preds = %4
  %22 = load i64, ptr %2, align 8
  %23 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %22)
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
