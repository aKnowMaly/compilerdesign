; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/select_ranges.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/select_ranges.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @select_ranges(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %.narrow = alloca [2 x i6], align 2
  %4 = and i32 %0, 63
  %5 = trunc i32 %4 to i16
  %6 = and i32 %1, 31
  %7 = trunc i32 %6 to i16
  %8 = icmp ne i32 %2, 0
  br i1 %8, label %9, label %11

9:                                                ; preds = %3
  %10 = zext i16 %5 to i32
  br label %13

11:                                               ; preds = %3
  %12 = zext i16 %7 to i32
  br label %13

13:                                               ; preds = %11, %9
  %14 = phi i32 [ %10, %9 ], [ %12, %11 ]
  %15 = trunc i32 %14 to i16
  %.narrow8 = getelementptr inbounds [2 x i6], ptr %.narrow, i64 0, i64 0
  %.narrow9 = trunc i16 %15 to i6
  store i6 %.narrow9, ptr %.narrow8, align 2
  %16 = icmp ne i32 %2, 0
  br i1 %16, label %17, label %19

17:                                               ; preds = %13
  %18 = zext i16 %7 to i32
  br label %21

19:                                               ; preds = %13
  %20 = zext i16 %5 to i32
  br label %21

21:                                               ; preds = %19, %17
  %22 = phi i32 [ %18, %17 ], [ %20, %19 ]
  %23 = trunc i32 %22 to i16
  %.narrow6 = getelementptr inbounds [2 x i6], ptr %.narrow, i64 0, i64 1
  %.narrow7 = trunc i16 %23 to i6
  store i6 %.narrow7, ptr %.narrow6, align 2
  %.narrow3 = getelementptr inbounds [2 x i6], ptr %.narrow, i64 0, i64 0
  %.narrow4 = load i6, ptr %.narrow3, align 2
  %.wide5 = zext i6 %.narrow4 to i16
  %24 = zext i16 %.wide5 to i32
  %.narrow1 = getelementptr inbounds [2 x i6], ptr %.narrow, i64 0, i64 1
  %.narrow2 = load i6, ptr %.narrow1, align 2
  %.wide = zext i6 %.narrow2 to i16
  %25 = zext i16 %.wide to i32
  %26 = add nsw i32 %24, %25
  ret i32 %26
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
