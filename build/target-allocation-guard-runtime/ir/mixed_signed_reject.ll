; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/mixed_signed_reject.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/mixed_signed_reject.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @mixed_signed_reject(i8 noundef signext %0, i8 noundef zeroext %1, i32 noundef %2) #0 {
  %4 = alloca [2 x i16], align 2
  %5 = sext i8 %0 to i16
  %6 = zext i8 %1 to i16
  %7 = icmp ne i32 %2, 0
  br i1 %7, label %8, label %10

8:                                                ; preds = %3
  %9 = sext i16 %5 to i32
  br label %12

10:                                               ; preds = %3
  %11 = sext i16 %6 to i32
  br label %12

12:                                               ; preds = %10, %8
  %13 = phi i32 [ %9, %8 ], [ %11, %10 ]
  %14 = trunc i32 %13 to i16
  %15 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  store i16 %14, ptr %15, align 2
  %16 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  %17 = load i16, ptr %16, align 2
  %18 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 1
  store i16 %17, ptr %18, align 2
  %19 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 1
  %20 = load i16, ptr %19, align 2
  ret i16 %20
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %25, %0
  %.02 = phi i32 [ -64, %0 ], [ %26, %25 ]
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %.1, %25 ]
  %2 = icmp sle i32 %.02, 63
  br i1 %2, label %3, label %27

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %22, %3
  %.03 = phi i32 [ 0, %3 ], [ %23, %22 ]
  %.1 = phi i64 [ %.01, %3 ], [ %.2, %22 ]
  %5 = icmp ult i32 %.03, 255
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
  %13 = call signext i16 @mixed_signed_reject(i8 noundef signext %11, i8 noundef zeroext %12, i32 noundef %.0)
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
  %23 = add i32 %.03, 29
  br label %4, !llvm.loop !8

24:                                               ; preds = %4
  br label %25

25:                                               ; preds = %24
  %26 = add nsw i32 %.02, 17
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
