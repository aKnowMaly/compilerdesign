; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/embedded_counters.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/embedded_counters.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @embedded_counters(i32 noundef %0) #0 {
  %.narrow = alloca [4 x i5], align 2
  %2 = and i32 %0, 15
  %3 = trunc i32 %2 to i16
  %.narrow18 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 0
  %.narrow19 = trunc i16 %3 to i5
  store i5 %.narrow19, ptr %.narrow18, align 2
  %4 = lshr i32 %0, 4
  %5 = and i32 %4, 15
  %6 = trunc i32 %5 to i16
  %.narrow16 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 1
  %.narrow17 = trunc i16 %6 to i5
  store i5 %.narrow17, ptr %.narrow16, align 2
  %7 = lshr i32 %0, 8
  %8 = and i32 %7, 15
  %9 = trunc i32 %8 to i16
  %.narrow14 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 2
  %.narrow15 = trunc i16 %9 to i5
  store i5 %.narrow15, ptr %.narrow14, align 2
  %.narrow11 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 0
  %.narrow12 = load i5, ptr %.narrow11, align 2
  %.wide13 = zext i5 %.narrow12 to i16
  %10 = zext i16 %.wide13 to i32
  %.narrow8 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 1
  %.narrow9 = load i5, ptr %.narrow8, align 2
  %.wide10 = zext i5 %.narrow9 to i16
  %11 = zext i16 %.wide10 to i32
  %12 = add nsw i32 %10, %11
  %.narrow5 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 2
  %.narrow6 = load i5, ptr %.narrow5, align 2
  %.wide7 = zext i5 %.narrow6 to i16
  %13 = zext i16 %.wide7 to i32
  %14 = add nsw i32 %12, %13
  %15 = and i32 %14, 31
  %16 = trunc i32 %15 to i16
  %.narrow3 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 3
  %.narrow4 = trunc i16 %16 to i5
  store i5 %.narrow4, ptr %.narrow3, align 2
  %.narrow1 = getelementptr inbounds [4 x i5], ptr %.narrow, i64 0, i64 3
  %.narrow2 = load i5, ptr %.narrow1, align 2
  %.wide = zext i5 %.narrow2 to i16
  %17 = zext i16 %.wide to i32
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
