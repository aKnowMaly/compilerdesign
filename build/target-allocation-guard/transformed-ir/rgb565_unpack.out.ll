; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/rgb565_unpack.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/rgb565_unpack.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @rgb565_unpack(i32 noundef %0) #0 {
  %.narrow = alloca [3 x i6], align 2
  %2 = lshr i32 %0, 11
  %3 = and i32 %2, 31
  %4 = trunc i32 %3 to i16
  %.narrow13 = getelementptr inbounds [3 x i6], ptr %.narrow, i64 0, i64 0
  %.narrow14 = trunc i16 %4 to i6
  store i6 %.narrow14, ptr %.narrow13, align 2
  %5 = lshr i32 %0, 5
  %6 = and i32 %5, 63
  %7 = trunc i32 %6 to i16
  %.narrow11 = getelementptr inbounds [3 x i6], ptr %.narrow, i64 0, i64 1
  %.narrow12 = trunc i16 %7 to i6
  store i6 %.narrow12, ptr %.narrow11, align 2
  %8 = and i32 %0, 31
  %9 = trunc i32 %8 to i16
  %.narrow9 = getelementptr inbounds [3 x i6], ptr %.narrow, i64 0, i64 2
  %.narrow10 = trunc i16 %9 to i6
  store i6 %.narrow10, ptr %.narrow9, align 2
  %.narrow6 = getelementptr inbounds [3 x i6], ptr %.narrow, i64 0, i64 0
  %.narrow7 = load i6, ptr %.narrow6, align 2
  %.wide8 = zext i6 %.narrow7 to i16
  %10 = zext i16 %.wide8 to i32
  %11 = mul i32 %10, 3
  %.narrow3 = getelementptr inbounds [3 x i6], ptr %.narrow, i64 0, i64 1
  %.narrow4 = load i6, ptr %.narrow3, align 2
  %.wide5 = zext i6 %.narrow4 to i16
  %12 = zext i16 %.wide5 to i32
  %13 = mul i32 %12, 5
  %14 = add i32 %11, %13
  %.narrow1 = getelementptr inbounds [3 x i6], ptr %.narrow, i64 0, i64 2
  %.narrow2 = load i6, ptr %.narrow1, align 2
  %.wide = zext i6 %.narrow2 to i16
  %15 = zext i16 %.wide to i32
  %16 = mul i32 %15, 7
  %17 = add i32 %14, %16
  ret i32 %17
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
