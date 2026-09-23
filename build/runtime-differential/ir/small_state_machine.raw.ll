; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/small_state_machine.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/small_state_machine.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @small_state_machine(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca [3 x i16], align 2
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %6 = load i32, ptr %3, align 4
  %7 = and i32 %6, 7
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 0
  store i16 %8, ptr %9, align 2
  %10 = load i32, ptr %4, align 4
  %11 = and i32 %10, 3
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 1
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 0
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 1
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  %20 = or i32 %16, %19
  %21 = and i32 %20, 7
  %22 = trunc i32 %21 to i16
  %23 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 2
  store i16 %22, ptr %23, align 2
  %24 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 2
  %25 = load i16, ptr %24, align 2
  %26 = zext i16 %25 to i32
  ret i32 %26
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 0, ptr %3, align 4
  br label %5

5:                                                ; preds = %27, %0
  %6 = load i32, ptr %3, align 4
  %7 = icmp ult i32 %6, 64
  br i1 %7, label %8, label %30

8:                                                ; preds = %5
  store i32 0, ptr %4, align 4
  br label %9

9:                                                ; preds = %23, %8
  %10 = load i32, ptr %4, align 4
  %11 = icmp ult i32 %10, 16
  br i1 %11, label %12, label %26

12:                                               ; preds = %9
  br label %13

13:                                               ; preds = %12
  %14 = load i32, ptr %3, align 4
  %15 = load i32, ptr %4, align 4
  %16 = call i32 @small_state_machine(i32 noundef %14, i32 noundef %15)
  %17 = zext i32 %16 to i64
  %18 = load i64, ptr %2, align 8
  %19 = xor i64 %18, %17
  store i64 %19, ptr %2, align 8
  %20 = load i64, ptr %2, align 8
  %21 = mul i64 %20, 1099511628211
  store i64 %21, ptr %2, align 8
  br label %22

22:                                               ; preds = %13
  br label %23

23:                                               ; preds = %22
  %24 = load i32, ptr %4, align 4
  %25 = add i32 %24, 2
  store i32 %25, ptr %4, align 4
  br label %9, !llvm.loop !6

26:                                               ; preds = %9
  br label %27

27:                                               ; preds = %26
  %28 = load i32, ptr %3, align 4
  %29 = add i32 %28, 3
  store i32 %29, ptr %3, align 4
  br label %5, !llvm.loop !8

30:                                               ; preds = %5
  %31 = load i64, ptr %2, align 8
  %32 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %31)
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
