; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/grayscale_threshold.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/grayscale_threshold.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @grayscale_threshold(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  %.narrow = alloca [4 x i8], align 2
  %5 = and i32 %0, 255
  %6 = trunc i32 %5 to i16
  %.narrow18 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow19 = trunc i16 %6 to i8
  store i8 %.narrow19, ptr %.narrow18, align 2
  %7 = and i32 %1, 255
  %8 = trunc i32 %7 to i16
  %.narrow16 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow17 = trunc i16 %8 to i8
  store i8 %.narrow17, ptr %.narrow16, align 2
  %9 = and i32 %2, 255
  %10 = trunc i32 %9 to i16
  %.narrow14 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow15 = trunc i16 %10 to i8
  store i8 %.narrow15, ptr %.narrow14, align 2
  %11 = and i32 %3, 255
  %12 = trunc i32 %11 to i16
  %.narrow12 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 3
  %.narrow13 = trunc i16 %12 to i8
  store i8 %.narrow13, ptr %.narrow12, align 2
  %.narrow9 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow10 = load i8, ptr %.narrow9, align 2
  %.wide11 = zext i8 %.narrow10 to i16
  %13 = zext i16 %.wide11 to i32
  %14 = icmp ugt i32 %13, 127
  %15 = zext i1 %14 to i32
  %.narrow6 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow7 = load i8, ptr %.narrow6, align 2
  %.wide8 = zext i8 %.narrow7 to i16
  %16 = zext i16 %.wide8 to i32
  %17 = icmp ugt i32 %16, 127
  %18 = zext i1 %17 to i32
  %19 = add nsw i32 %15, %18
  %.narrow3 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow4 = load i8, ptr %.narrow3, align 2
  %.wide5 = zext i8 %.narrow4 to i16
  %20 = zext i16 %.wide5 to i32
  %21 = icmp ugt i32 %20, 127
  %22 = zext i1 %21 to i32
  %23 = add nsw i32 %19, %22
  %.narrow1 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 3
  %.narrow2 = load i8, ptr %.narrow1, align 2
  %.wide = zext i8 %.narrow2 to i16
  %24 = zext i16 %.wide to i32
  %25 = icmp ugt i32 %24, 127
  %26 = zext i1 %25 to i32
  %27 = add nsw i32 %23, %26
  ret i32 %27
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
