; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/signed_delta_pair.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/signed_delta_pair.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_delta_pair(i8 noundef signext %0, i8 noundef signext %1) #0 {
  %3 = alloca [2 x i16], align 2
  %4 = sext i8 %0 to i16
  %5 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store i16 %4, ptr %5, align 2
  %6 = sext i8 %1 to i16
  %7 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  store i16 %6, ptr %7, align 2
  %8 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %9 = load i16, ptr %8, align 2
  %10 = sext i16 %9 to i32
  %11 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %12 = load i16, ptr %11, align 2
  %13 = sext i16 %12 to i32
  %14 = sub nsw i32 %10, %13
  %15 = trunc i32 %14 to i16
  ret i16 %15
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %19, %0
  %.02 = phi i32 [ -96, %0 ], [ %20, %19 ]
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %.1, %19 ]
  %2 = icmp sle i32 %.02, 96
  br i1 %2, label %3, label %21

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %16, %3
  %.1 = phi i64 [ %.01, %3 ], [ %14, %16 ]
  %.0 = phi i32 [ -80, %3 ], [ %17, %16 ]
  %5 = icmp sle i32 %.0, 80
  br i1 %5, label %6, label %18

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %6
  %8 = trunc i32 %.02 to i8
  %9 = trunc i32 %.0 to i8
  %10 = call signext i16 @signed_delta_pair(i8 noundef signext %8, i8 noundef signext %9)
  %11 = sext i16 %10 to i32
  %12 = zext i32 %11 to i64
  %13 = xor i64 %.1, %12
  %14 = mul i64 %13, 1099511628211
  br label %15

15:                                               ; preds = %7
  br label %16

16:                                               ; preds = %15
  %17 = add nsw i32 %.0, 29
  br label %4, !llvm.loop !6

18:                                               ; preds = %4
  br label %19

19:                                               ; preds = %18
  %20 = add nsw i32 %.02, 31
  br label %1, !llvm.loop !8

21:                                               ; preds = %1
  %22 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
