; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/protocol_version_table.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/protocol_version_table.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @protocol_version_table(i32 noundef %0) #0 {
  %.narrow = alloca [3 x i5], align 2
  %2 = lshr i32 %0, 29
  %3 = and i32 %2, 7
  %4 = trunc i32 %3 to i16
  %.narrow19 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 0
  %.narrow20 = trunc i16 %4 to i5
  store i5 %.narrow20, ptr %.narrow19, align 2
  %5 = lshr i32 %0, 24
  %6 = and i32 %5, 31
  %7 = trunc i32 %6 to i16
  %.narrow17 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 1
  %.narrow18 = trunc i16 %7 to i5
  store i5 %.narrow18, ptr %.narrow17, align 2
  %.narrow14 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 0
  %.narrow15 = load i5, ptr %.narrow14, align 2
  %.wide16 = zext i5 %.narrow15 to i16
  %8 = zext i16 %.wide16 to i32
  %.narrow11 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 1
  %.narrow12 = load i5, ptr %.narrow11, align 2
  %.wide13 = zext i5 %.narrow12 to i16
  %9 = zext i16 %.wide13 to i32
  %10 = or i32 %8, %9
  %11 = and i32 %10, 31
  %12 = trunc i32 %11 to i16
  %.narrow9 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 2
  %.narrow10 = trunc i16 %12 to i5
  store i5 %.narrow10, ptr %.narrow9, align 2
  %.narrow6 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 0
  %.narrow7 = load i5, ptr %.narrow6, align 2
  %.wide8 = zext i5 %.narrow7 to i16
  %13 = zext i16 %.wide8 to i32
  %.narrow3 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 1
  %.narrow4 = load i5, ptr %.narrow3, align 2
  %.wide5 = zext i5 %.narrow4 to i16
  %14 = zext i16 %.wide5 to i32
  %15 = add nsw i32 %13, %14
  %.narrow1 = getelementptr inbounds [3 x i5], ptr %.narrow, i64 0, i64 2
  %.narrow2 = load i5, ptr %.narrow1, align 2
  %.wide = zext i5 %.narrow2 to i16
  %16 = zext i16 %.wide to i32
  %17 = add nsw i32 %15, %16
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
