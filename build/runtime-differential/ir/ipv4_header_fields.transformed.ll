; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/ir/ipv4_header_fields.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/ipv4_header_fields.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @ipv4_header_fields(i32 noundef %0, i32 noundef %1) #0 {
  %.narrow = alloca [4 x i8], align 2
  %3 = lshr i32 %0, 28
  %4 = and i32 %3, 15
  %5 = trunc i32 %4 to i16
  %.narrow18 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow19 = trunc i16 %5 to i8
  store i8 %.narrow19, ptr %.narrow18, align 2
  %6 = lshr i32 %0, 24
  %7 = and i32 %6, 15
  %8 = trunc i32 %7 to i16
  %.narrow16 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow17 = trunc i16 %8 to i8
  store i8 %.narrow17, ptr %.narrow16, align 2
  %9 = and i32 %0, 255
  %10 = trunc i32 %9 to i16
  %.narrow14 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow15 = trunc i16 %10 to i8
  store i8 %.narrow15, ptr %.narrow14, align 2
  %11 = lshr i32 %1, 16
  %12 = and i32 %11, 63
  %13 = trunc i32 %12 to i16
  %.narrow12 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 3
  %.narrow13 = trunc i16 %13 to i8
  store i8 %.narrow13, ptr %.narrow12, align 2
  %.narrow9 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow10 = load i8, ptr %.narrow9, align 2
  %.wide11 = zext i8 %.narrow10 to i16
  %14 = zext i16 %.wide11 to i32
  %.narrow6 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow7 = load i8, ptr %.narrow6, align 2
  %.wide8 = zext i8 %.narrow7 to i16
  %15 = zext i16 %.wide8 to i32
  %16 = add nsw i32 %14, %15
  %.narrow3 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow4 = load i8, ptr %.narrow3, align 2
  %.wide5 = zext i8 %.narrow4 to i16
  %17 = zext i16 %.wide5 to i32
  %18 = add nsw i32 %16, %17
  %.narrow1 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 3
  %.narrow2 = load i8, ptr %.narrow1, align 2
  %.wide = zext i8 %.narrow2 to i16
  %19 = zext i16 %.wide to i32
  %20 = add nsw i32 %18, %19
  ret i32 %20
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %12, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %10, %12 ]
  %.0 = phi i32 [ 0, %0 ], [ %13, %12 ]
  %2 = icmp ult i32 %.0, 128
  br i1 %2, label %3, label %14

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = mul i32 %.0, 19088743
  %6 = mul i32 %.0, 124076833
  %7 = call i32 @ipv4_header_fields(i32 noundef %5, i32 noundef %6)
  %8 = zext i32 %7 to i64
  %9 = xor i64 %.01, %8
  %10 = mul i64 %9, 1099511628211
  br label %11

11:                                               ; preds = %4
  br label %12

12:                                               ; preds = %11
  %13 = add i32 %.0, 7
  br label %1, !llvm.loop !6

14:                                               ; preds = %1
  %15 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
