; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/pixel_channels.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/pixel_channels.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @pixel_channels(i32 noundef %0) #0 {
  %.narrow = alloca [4 x i8], align 2
  %2 = and i32 %0, 255
  %3 = trunc i32 %2 to i16
  %.narrow18 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow19 = trunc i16 %3 to i8
  store i8 %.narrow19, ptr %.narrow18, align 2
  %4 = lshr i32 %0, 8
  %5 = and i32 %4, 255
  %6 = trunc i32 %5 to i16
  %.narrow16 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow17 = trunc i16 %6 to i8
  store i8 %.narrow17, ptr %.narrow16, align 2
  %7 = lshr i32 %0, 16
  %8 = and i32 %7, 255
  %9 = trunc i32 %8 to i16
  %.narrow14 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow15 = trunc i16 %9 to i8
  store i8 %.narrow15, ptr %.narrow14, align 2
  %10 = lshr i32 %0, 24
  %11 = and i32 %10, 255
  %12 = trunc i32 %11 to i16
  %.narrow12 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 3
  %.narrow13 = trunc i16 %12 to i8
  store i8 %.narrow13, ptr %.narrow12, align 2
  %.narrow9 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow10 = load i8, ptr %.narrow9, align 2
  %.wide11 = zext i8 %.narrow10 to i16
  %13 = zext i16 %.wide11 to i32
  %.narrow6 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow7 = load i8, ptr %.narrow6, align 2
  %.wide8 = zext i8 %.narrow7 to i16
  %14 = zext i16 %.wide8 to i32
  %15 = add nsw i32 %13, %14
  %.narrow3 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 2
  %.narrow4 = load i8, ptr %.narrow3, align 2
  %.wide5 = zext i8 %.narrow4 to i16
  %16 = zext i16 %.wide5 to i32
  %17 = add nsw i32 %15, %16
  %.narrow1 = getelementptr inbounds [4 x i8], ptr %.narrow, i64 0, i64 3
  %.narrow2 = load i8, ptr %.narrow1, align 2
  %.wide = zext i8 %.narrow2 to i16
  %18 = zext i16 %.wide to i32
  %19 = add nsw i32 %17, %18
  ret i32 %19
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
