; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/signed_offsets.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/signed_offsets.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_offsets(i8 noundef signext %0, i8 noundef signext %1, i32 noundef %2) #0 {
  %.narrow = alloca [2 x i8], align 2
  %4 = sext i8 %0 to i16
  %5 = sext i8 %1 to i16
  %.narrow8 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow9 = trunc i16 %4 to i8
  store i8 %.narrow9, ptr %.narrow8, align 2
  %.narrow6 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow7 = trunc i16 %5 to i8
  store i8 %.narrow7, ptr %.narrow6, align 2
  %6 = icmp ne i32 %2, 0
  br i1 %6, label %7, label %9

7:                                                ; preds = %3
  %.narrow3 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow4 = load i8, ptr %.narrow3, align 2
  %.wide5 = sext i8 %.narrow4 to i16
  %8 = sext i16 %.wide5 to i32
  br label %11

9:                                                ; preds = %3
  %.narrow1 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow2 = load i8, ptr %.narrow1, align 2
  %.wide = sext i8 %.narrow2 to i16
  %10 = sext i16 %.wide to i32
  br label %11

11:                                               ; preds = %9, %7
  %12 = phi i32 [ %8, %7 ], [ %10, %9 ]
  %13 = trunc i32 %12 to i16
  ret i16 %13
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %25, %0
  %.02 = phi i32 [ -96, %0 ], [ %26, %25 ]
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %.1, %25 ]
  %2 = icmp sle i32 %.02, 96
  br i1 %2, label %3, label %27

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %22, %3
  %.03 = phi i32 [ -80, %3 ], [ %23, %22 ]
  %.1 = phi i64 [ %.01, %3 ], [ %.2, %22 ]
  %5 = icmp sle i32 %.03, 80
  br i1 %5, label %6, label %24

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %19, %6
  %.2 = phi i64 [ %.1, %6 ], [ %17, %19 ]
  %.0 = phi i32 [ 0, %6 ], [ %20, %19 ]
  %8 = icmp slt i32 %.0, 2
  br i1 %8, label %9, label %21

9:                                                ; preds = %7
  br label %10

10:                                               ; preds = %9
  %11 = trunc i32 %.02 to i8
  %12 = trunc i32 %.03 to i8
  %13 = call signext i16 @signed_offsets(i8 noundef signext %11, i8 noundef signext %12, i32 noundef %.0)
  %14 = sext i16 %13 to i32
  %15 = zext i32 %14 to i64
  %16 = xor i64 %.2, %15
  %17 = mul i64 %16, 1099511628211
  br label %18

18:                                               ; preds = %10
  br label %19

19:                                               ; preds = %18
  %20 = add nsw i32 %.0, 1
  br label %7, !llvm.loop !6

21:                                               ; preds = %7
  br label %22

22:                                               ; preds = %21
  %23 = add nsw i32 %.03, 29
  br label %4, !llvm.loop !8

24:                                               ; preds = %4
  br label %25

25:                                               ; preds = %24
  %26 = add nsw i32 %.02, 31
  br label %1, !llvm.loop !9

27:                                               ; preds = %1
  %28 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
!9 = distinct !{!9, !7}
