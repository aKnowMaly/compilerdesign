; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/quantized_filter.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/quantized_filter.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @quantized_filter(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca [3 x i16], align 2
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %6 = load i32, ptr %3, align 4
  %7 = and i32 %6, 63
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 0
  store i16 %8, ptr %9, align 2
  %10 = load i32, ptr %4, align 4
  %11 = and i32 %10, 63
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 1
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 0
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = getelementptr inbounds [3 x i16], ptr %5, i64 0, i64 1
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  %20 = add nsw i32 %16, %19
  %21 = and i32 %20, 127
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
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 0, ptr %3, align 4
  br label %4

4:                                                ; preds = %20, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 128
  br i1 %6, label %7, label %23

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = mul i32 %9, 11
  %11 = load i32, ptr %3, align 4
  %12 = mul i32 %11, 17
  %13 = call i32 @quantized_filter(i32 noundef %10, i32 noundef %12)
  %14 = zext i32 %13 to i64
  %15 = load i64, ptr %2, align 8
  %16 = xor i64 %15, %14
  store i64 %16, ptr %2, align 8
  %17 = load i64, ptr %2, align 8
  %18 = mul i64 %17, 1099511628211
  store i64 %18, ptr %2, align 8
  br label %19

19:                                               ; preds = %8
  br label %20

20:                                               ; preds = %19
  %21 = load i32, ptr %3, align 4
  %22 = add i32 %21, 5
  store i32 %22, ptr %3, align 4
  br label %4, !llvm.loop !6

23:                                               ; preds = %4
  %24 = load i64, ptr %2, align 8
  %25 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %24)
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
