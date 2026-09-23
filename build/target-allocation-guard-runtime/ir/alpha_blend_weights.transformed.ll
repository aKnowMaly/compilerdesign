; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/alpha_blend_weights.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/alpha_blend_weights.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @alpha_blend_weights(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %.narrow = alloca [3 x i8], align 2
  %4 = and i32 %0, 255
  %5 = trunc i32 %4 to i16
  %.narrow16 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow17 = trunc i16 %5 to i8
  store i8 %.narrow17, ptr %.narrow16, align 2
  %6 = and i32 %1, 255
  %7 = trunc i32 %6 to i16
  %.narrow14 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow15 = trunc i16 %7 to i8
  store i8 %.narrow15, ptr %.narrow14, align 2
  %8 = and i32 %2, 255
  %9 = trunc i32 %8 to i16
  %.narrow12 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow13 = trunc i16 %9 to i8
  store i8 %.narrow13, ptr %.narrow12, align 2
  %.narrow9 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow10 = load i8, ptr %.narrow9, align 2
  %.wide11 = zext i8 %.narrow10 to i16
  %10 = zext i16 %.wide11 to i32
  %.narrow6 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow7 = load i8, ptr %.narrow6, align 2
  %.wide8 = zext i8 %.narrow7 to i16
  %11 = zext i16 %.wide8 to i32
  %12 = mul nsw i32 %10, %11
  %.narrow3 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow4 = load i8, ptr %.narrow3, align 2
  %.wide5 = zext i8 %.narrow4 to i16
  %13 = zext i16 %.wide5 to i32
  %14 = sub i32 255, %13
  %.narrow1 = getelementptr inbounds [3 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow2 = load i8, ptr %.narrow1, align 2
  %.wide = zext i8 %.narrow2 to i16
  %15 = zext i16 %.wide to i32
  %16 = mul i32 %14, %15
  %17 = add i32 %12, %16
  %18 = lshr i32 %17, 8
  ret i32 %18
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
  %5 = mul i32 %.0, 3
  %6 = mul i32 %.0, 17
  %7 = mul i32 %.0, 29
  %8 = call i32 @alpha_blend_weights(i32 noundef %5, i32 noundef %6, i32 noundef %7)
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
