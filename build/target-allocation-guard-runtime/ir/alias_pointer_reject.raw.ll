; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/alias_pointer_reject.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/alias_pointer_reject.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @alias_pointer_reject(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca [2 x i16], align 2
  %6 = alloca ptr, align 8
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %7 = load i32, ptr %4, align 4
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %9, label %11

9:                                                ; preds = %2
  %10 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 1
  br label %13

11:                                               ; preds = %2
  %12 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 0
  br label %13

13:                                               ; preds = %11, %9
  %14 = phi ptr [ %10, %9 ], [ %12, %11 ]
  store ptr %14, ptr %6, align 8
  %15 = load i32, ptr %3, align 4
  %16 = and i32 %15, 31
  %17 = trunc i32 %16 to i16
  %18 = load ptr, ptr %6, align 8
  store i16 %17, ptr %18, align 2
  %19 = load i32, ptr %4, align 4
  %20 = icmp ne i32 %19, 0
  %21 = zext i1 %20 to i64
  %22 = select i1 %20, i32 1, i32 0
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds [2 x i16], ptr %5, i64 0, i64 %23
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

5:                                                ; preds = %28, %0
  %6 = load i32, ptr %3, align 4
  %7 = icmp ult i32 %6, 128
  br i1 %7, label %8, label %31

8:                                                ; preds = %5
  store i32 0, ptr %4, align 4
  br label %9

9:                                                ; preds = %24, %8
  %10 = load i32, ptr %4, align 4
  %11 = icmp slt i32 %10, 2
  br i1 %11, label %12, label %27

12:                                               ; preds = %9
  br label %13

13:                                               ; preds = %12
  %14 = load i32, ptr %3, align 4
  %15 = mul i32 %14, 13
  %16 = load i32, ptr %4, align 4
  %17 = call i32 @alias_pointer_reject(i32 noundef %15, i32 noundef %16)
  %18 = zext i32 %17 to i64
  %19 = load i64, ptr %2, align 8
  %20 = xor i64 %19, %18
  store i64 %20, ptr %2, align 8
  %21 = load i64, ptr %2, align 8
  %22 = mul i64 %21, 1099511628211
  store i64 %22, ptr %2, align 8
  br label %23

23:                                               ; preds = %13
  br label %24

24:                                               ; preds = %23
  %25 = load i32, ptr %4, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, ptr %4, align 4
  br label %9, !llvm.loop !6

27:                                               ; preds = %9
  br label %28

28:                                               ; preds = %27
  %29 = load i32, ptr %3, align 4
  %30 = add i32 %29, 9
  store i32 %30, ptr %3, align 4
  br label %5, !llvm.loop !8

31:                                               ; preds = %5
  %32 = load i64, ptr %2, align 8
  %33 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %32)
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
