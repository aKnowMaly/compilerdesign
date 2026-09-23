; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/select_ranges.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/select_ranges.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @select_ranges(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca [2 x i16], align 2
  %5 = and i32 %0, 63
  %6 = trunc i32 %5 to i16
  %7 = and i32 %1, 31
  %8 = trunc i32 %7 to i16
  %9 = icmp ne i32 %2, 0
  br i1 %9, label %10, label %12

10:                                               ; preds = %3
  %11 = zext i16 %6 to i32
  br label %14

12:                                               ; preds = %3
  %13 = zext i16 %8 to i32
  br label %14

14:                                               ; preds = %12, %10
  %15 = phi i32 [ %11, %10 ], [ %13, %12 ]
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  store i16 %16, ptr %17, align 2
  %18 = icmp ne i32 %2, 0
  br i1 %18, label %19, label %21

19:                                               ; preds = %14
  %20 = zext i16 %8 to i32
  br label %23

21:                                               ; preds = %14
  %22 = zext i16 %6 to i32
  br label %23

23:                                               ; preds = %21, %19
  %24 = phi i32 [ %20, %19 ], [ %22, %21 ]
  %25 = trunc i32 %24 to i16
  %26 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 1
  store i16 %25, ptr %26, align 2
  %27 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  %28 = load i16, ptr %27, align 2
  %29 = zext i16 %28 to i32
  %30 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 1
  %31 = load i16, ptr %30, align 2
  %32 = zext i16 %31 to i32
  %33 = add nsw i32 %29, %32
  ret i32 %33
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
