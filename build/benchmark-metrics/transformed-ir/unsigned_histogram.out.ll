; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/unsigned_histogram.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/unsigned_histogram.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@bins = internal global [4 x i16] [i16 1, i16 3, i16 7, i16 15], align 2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @unsigned_histogram(ptr noundef %0, i32 noundef %1) #0 {
  %.narrow = alloca [4 x i7], align 2
  %3 = getelementptr inbounds i32, ptr %0, i64 0
  %4 = load i32, ptr %3, align 4
  %5 = and i32 %4, 15
  %6 = trunc i32 %5 to i16
  %.narrow9 = getelementptr inbounds [4 x i7], ptr %.narrow, i64 0, i64 0
  %.narrow10 = trunc i16 %6 to i7
  store i7 %.narrow10, ptr %.narrow9, align 2
  %7 = getelementptr inbounds i32, ptr %0, i64 1
  %8 = load i32, ptr %7, align 4
  %9 = and i32 %8, 31
  %10 = trunc i32 %9 to i16
  %.narrow7 = getelementptr inbounds [4 x i7], ptr %.narrow, i64 0, i64 1
  %.narrow8 = trunc i16 %10 to i7
  store i7 %.narrow8, ptr %.narrow7, align 2
  %11 = getelementptr inbounds i32, ptr %0, i64 2
  %12 = load i32, ptr %11, align 4
  %13 = and i32 %12, 63
  %14 = trunc i32 %13 to i16
  %.narrow5 = getelementptr inbounds [4 x i7], ptr %.narrow, i64 0, i64 2
  %.narrow6 = trunc i16 %14 to i7
  store i7 %.narrow6, ptr %.narrow5, align 2
  %15 = getelementptr inbounds i32, ptr %0, i64 3
  %16 = load i32, ptr %15, align 4
  %17 = and i32 %16, 127
  %18 = trunc i32 %17 to i16
  %.narrow3 = getelementptr inbounds [4 x i7], ptr %.narrow, i64 0, i64 3
  %.narrow4 = trunc i16 %18 to i7
  store i7 %.narrow4, ptr %.narrow3, align 2
  br label %19

19:                                               ; preds = %34, %2
  %.01 = phi i32 [ 0, %2 ], [ %33, %34 ]
  %.0 = phi i32 [ 0, %2 ], [ %35, %34 ]
  %20 = icmp ult i32 %.0, 4
  br i1 %20, label %21, label %23

21:                                               ; preds = %19
  %22 = icmp ult i32 %.0, %1
  br label %23

23:                                               ; preds = %21, %19
  %24 = phi i1 [ false, %19 ], [ %22, %21 ]
  br i1 %24, label %25, label %36

25:                                               ; preds = %23
  %26 = zext i32 %.0 to i64
  %.narrow1 = getelementptr inbounds [4 x i7], ptr %.narrow, i64 0, i64 %26
  %.narrow2 = load i7, ptr %.narrow1, align 2
  %.wide = zext i7 %.narrow2 to i16
  %27 = zext i16 %.wide to i32
  %28 = zext i32 %.0 to i64
  %29 = getelementptr inbounds [4 x i16], ptr @bins, i64 0, i64 %28
  %30 = load i16, ptr %29, align 2
  %31 = zext i16 %30 to i32
  %32 = add nsw i32 %27, %31
  %33 = add i32 %.01, %32
  br label %34

34:                                               ; preds = %25
  %35 = add i32 %.0, 1
  br label %19, !llvm.loop !6

36:                                               ; preds = %23
  ret i32 %.01
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
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
