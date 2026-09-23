; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/select_ranges.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/select_ranges.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @select_ranges(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca [2 x i16], align 2
  %8 = alloca i16, align 2
  %9 = alloca i16, align 2
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  store i32 %2, ptr %6, align 4
  %10 = load i32, ptr %4, align 4
  %11 = and i32 %10, 63
  %12 = trunc i32 %11 to i16
  store i16 %12, ptr %8, align 2
  %13 = load i32, ptr %5, align 4
  %14 = and i32 %13, 31
  %15 = trunc i32 %14 to i16
  store i16 %15, ptr %9, align 2
  %16 = load i32, ptr %6, align 4
  %17 = icmp ne i32 %16, 0
  br i1 %17, label %18, label %21

18:                                               ; preds = %3
  %19 = load i16, ptr %8, align 2
  %20 = zext i16 %19 to i32
  br label %24

21:                                               ; preds = %3
  %22 = load i16, ptr %9, align 2
  %23 = zext i16 %22 to i32
  br label %24

24:                                               ; preds = %21, %18
  %25 = phi i32 [ %20, %18 ], [ %23, %21 ]
  %26 = trunc i32 %25 to i16
  %27 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 0
  store i16 %26, ptr %27, align 2
  %28 = load i32, ptr %6, align 4
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %30, label %33

30:                                               ; preds = %24
  %31 = load i16, ptr %9, align 2
  %32 = zext i16 %31 to i32
  br label %36

33:                                               ; preds = %24
  %34 = load i16, ptr %8, align 2
  %35 = zext i16 %34 to i32
  br label %36

36:                                               ; preds = %33, %30
  %37 = phi i32 [ %32, %30 ], [ %35, %33 ]
  %38 = trunc i32 %37 to i16
  %39 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 1
  store i16 %38, ptr %39, align 2
  %40 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 0
  %41 = load i16, ptr %40, align 2
  %42 = zext i16 %41 to i32
  %43 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 1
  %44 = load i16, ptr %43, align 2
  %45 = zext i16 %44 to i32
  %46 = add nsw i32 %42, %45
  ret i32 %46
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
