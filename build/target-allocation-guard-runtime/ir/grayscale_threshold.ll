; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/grayscale_threshold.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/grayscale_threshold.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @grayscale_threshold(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  %5 = alloca [4 x i16], align 2
  %6 = and i32 %0, 255
  %7 = trunc i32 %6 to i16
  %8 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  store i16 %7, ptr %8, align 2
  %9 = and i32 %1, 255
  %10 = trunc i32 %9 to i16
  %11 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  store i16 %10, ptr %11, align 2
  %12 = and i32 %2, 255
  %13 = trunc i32 %12 to i16
  %14 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  store i16 %13, ptr %14, align 2
  %15 = and i32 %3, 255
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  store i16 %16, ptr %17, align 2
  %18 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  %19 = load i16, ptr %18, align 2
  %20 = zext i16 %19 to i32
  %21 = icmp ugt i32 %20, 127
  %22 = zext i1 %21 to i32
  %23 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  %24 = load i16, ptr %23, align 2
  %25 = zext i16 %24 to i32
  %26 = icmp ugt i32 %25, 127
  %27 = zext i1 %26 to i32
  %28 = add nsw i32 %22, %27
  %29 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  %30 = load i16, ptr %29, align 2
  %31 = zext i16 %30 to i32
  %32 = icmp ugt i32 %31, 127
  %33 = zext i1 %32 to i32
  %34 = add nsw i32 %28, %33
  %35 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  %36 = load i16, ptr %35, align 2
  %37 = zext i16 %36 to i32
  %38 = icmp ugt i32 %37, 127
  %39 = zext i1 %38 to i32
  %40 = add nsw i32 %34, %39
  ret i32 %40
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %13, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %11, %13 ]
  %.0 = phi i32 [ 0, %0 ], [ %14, %13 ]
  %2 = icmp ult i32 %.0, 128
  br i1 %2, label %3, label %15

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = mul i32 %.0, 2
  %6 = mul i32 %.0, 3
  %7 = mul i32 %.0, 4
  %8 = call i32 @grayscale_threshold(i32 noundef %.0, i32 noundef %5, i32 noundef %6, i32 noundef %7)
  %9 = zext i32 %8 to i64
  %10 = xor i64 %.01, %9
  %11 = mul i64 %10, 1099511628211
  br label %12

12:                                               ; preds = %4
  br label %13

13:                                               ; preds = %12
  %14 = add i32 %.0, 5
  br label %1, !llvm.loop !6

15:                                               ; preds = %1
  %16 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
