; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/unsigned_histogram.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/unsigned_histogram.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@bins = internal global [4 x i16] [i16 1, i16 3, i16 7, i16 15], align 2
@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

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

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca [4 x i32], align 16
  br label %2

2:                                                ; preds = %19, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %17, %19 ]
  %.0 = phi i32 [ 0, %0 ], [ %20, %19 ]
  %3 = icmp ult i32 %.0, 128
  br i1 %3, label %4, label %21

4:                                                ; preds = %2
  %5 = getelementptr inbounds [4 x i32], ptr %1, i64 0, i64 0
  store i32 %.0, ptr %5, align 16
  %6 = mul i32 %.0, 3
  %7 = getelementptr inbounds [4 x i32], ptr %1, i64 0, i64 1
  store i32 %6, ptr %7, align 4
  %8 = mul i32 %.0, 5
  %9 = getelementptr inbounds [4 x i32], ptr %1, i64 0, i64 2
  store i32 %8, ptr %9, align 8
  %10 = mul i32 %.0, 7
  %11 = getelementptr inbounds [4 x i32], ptr %1, i64 0, i64 3
  store i32 %10, ptr %11, align 4
  br label %12

12:                                               ; preds = %4
  %13 = getelementptr inbounds [4 x i32], ptr %1, i64 0, i64 0
  %14 = call i32 @unsigned_histogram(ptr noundef %13, i32 noundef 4)
  %15 = zext i32 %14 to i64
  %16 = xor i64 %.01, %15
  %17 = mul i64 %16, 1099511628211
  br label %18

18:                                               ; preds = %12
  br label %19

19:                                               ; preds = %18
  %20 = add i32 %.0, 13
  br label %2, !llvm.loop !8

21:                                               ; preds = %2
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
