; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/unsigned_histogram.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/unsigned_histogram.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@bins = internal global [4 x i16] [i16 1, i16 3, i16 7, i16 15], align 2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @unsigned_histogram(ptr noundef %0, i32 noundef %1) #0 {
  %3 = alloca [4 x i16], align 2
  %4 = getelementptr inbounds i32, ptr %0, i64 0
  %5 = load i32, ptr %4, align 4
  %6 = and i32 %5, 15
  %7 = trunc i32 %6 to i16
  %8 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  store i16 %7, ptr %8, align 2
  %9 = getelementptr inbounds i32, ptr %0, i64 1
  %10 = load i32, ptr %9, align 4
  %11 = and i32 %10, 31
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds i32, ptr %0, i64 2
  %15 = load i32, ptr %14, align 4
  %16 = and i32 %15, 63
  %17 = trunc i32 %16 to i16
  %18 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  store i16 %17, ptr %18, align 2
  %19 = getelementptr inbounds i32, ptr %0, i64 3
  %20 = load i32, ptr %19, align 4
  %21 = and i32 %20, 127
  %22 = trunc i32 %21 to i16
  %23 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  store i16 %22, ptr %23, align 2
  br label %24

24:                                               ; preds = %41, %2
  %.01 = phi i32 [ 0, %2 ], [ %40, %41 ]
  %.0 = phi i32 [ 0, %2 ], [ %42, %41 ]
  %25 = icmp ult i32 %.0, 4
  br i1 %25, label %26, label %28

26:                                               ; preds = %24
  %27 = icmp ult i32 %.0, %1
  br label %28

28:                                               ; preds = %26, %24
  %29 = phi i1 [ false, %24 ], [ %27, %26 ]
  br i1 %29, label %30, label %43

30:                                               ; preds = %28
  %31 = zext i32 %.0 to i64
  %32 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 %31
  %33 = load i16, ptr %32, align 2
  %34 = zext i16 %33 to i32
  %35 = zext i32 %.0 to i64
  %36 = getelementptr inbounds [4 x i16], ptr @bins, i64 0, i64 %35
  %37 = load i16, ptr %36, align 2
  %38 = zext i16 %37 to i32
  %39 = add nsw i32 %34, %38
  %40 = add i32 %.01, %39
  br label %41

41:                                               ; preds = %30
  %42 = add i32 %.0, 1
  br label %24, !llvm.loop !6

43:                                               ; preds = %28
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
