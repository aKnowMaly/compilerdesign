; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_select_offsets.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_select_offsets.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_select_offsets(i8 noundef signext %0, i8 noundef signext %1, i32 noundef %2) #0 {
  %4 = alloca i8, align 1
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca [3 x i16], align 2
  %8 = alloca i16, align 2
  %9 = alloca i16, align 2
  store i8 %0, ptr %4, align 1
  store i8 %1, ptr %5, align 1
  store i32 %2, ptr %6, align 4
  %10 = load i8, ptr %4, align 1
  %11 = sext i8 %10 to i16
  store i16 %11, ptr %8, align 2
  %12 = load i8, ptr %5, align 1
  %13 = sext i8 %12 to i16
  store i16 %13, ptr %9, align 2
  %14 = load i32, ptr %6, align 4
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %16, label %19

16:                                               ; preds = %3
  %17 = load i16, ptr %8, align 2
  %18 = sext i16 %17 to i32
  br label %22

19:                                               ; preds = %3
  %20 = load i16, ptr %9, align 2
  %21 = sext i16 %20 to i32
  br label %22

22:                                               ; preds = %19, %16
  %23 = phi i32 [ %18, %16 ], [ %21, %19 ]
  %24 = trunc i32 %23 to i16
  %25 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 0
  store i16 %24, ptr %25, align 2
  %26 = load i32, ptr %6, align 4
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %28, label %31

28:                                               ; preds = %22
  %29 = load i16, ptr %9, align 2
  %30 = sext i16 %29 to i32
  br label %34

31:                                               ; preds = %22
  %32 = load i16, ptr %8, align 2
  %33 = sext i16 %32 to i32
  br label %34

34:                                               ; preds = %31, %28
  %35 = phi i32 [ %30, %28 ], [ %33, %31 ]
  %36 = trunc i32 %35 to i16
  %37 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 1
  store i16 %36, ptr %37, align 2
  %38 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 0
  %39 = load i16, ptr %38, align 2
  %40 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 2
  store i16 %39, ptr %40, align 2
  %41 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 1
  %42 = load i16, ptr %41, align 2
  %43 = sext i16 %42 to i32
  %44 = getelementptr inbounds [3 x i16], ptr %7, i64 0, i64 2
  %45 = load i16, ptr %44, align 2
  %46 = sext i16 %45 to i32
  %47 = add nsw i32 %43, %46
  %48 = trunc i32 %47 to i16
  ret i16 %48
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
