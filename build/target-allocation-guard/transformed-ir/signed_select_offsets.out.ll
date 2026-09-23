; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/signed_select_offsets.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_select_offsets.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_select_offsets(i8 noundef signext %0, i8 noundef signext %1, i32 noundef %2) #0 {
  %4 = alloca [3 x i16], align 2
  %5 = sext i8 %0 to i16
  %6 = sext i8 %1 to i16
  %7 = icmp ne i32 %2, 0
  br i1 %7, label %8, label %10

8:                                                ; preds = %3
  %9 = sext i16 %5 to i32
  br label %12

10:                                               ; preds = %3
  %11 = sext i16 %6 to i32
  br label %12

12:                                               ; preds = %10, %8
  %13 = phi i32 [ %9, %8 ], [ %11, %10 ]
  %14 = trunc i32 %13 to i16
  %15 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 0
  store i16 %14, ptr %15, align 2
  %16 = icmp ne i32 %2, 0
  br i1 %16, label %17, label %19

17:                                               ; preds = %12
  %18 = sext i16 %6 to i32
  br label %21

19:                                               ; preds = %12
  %20 = sext i16 %5 to i32
  br label %21

21:                                               ; preds = %19, %17
  %22 = phi i32 [ %18, %17 ], [ %20, %19 ]
  %23 = trunc i32 %22 to i16
  %24 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 1
  store i16 %23, ptr %24, align 2
  %25 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 0
  %26 = load i16, ptr %25, align 2
  %27 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 2
  store i16 %26, ptr %27, align 2
  %28 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 1
  %29 = load i16, ptr %28, align 2
  %30 = sext i16 %29 to i32
  %31 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 2
  %32 = load i16, ptr %31, align 2
  %33 = sext i16 %32 to i32
  %34 = add nsw i32 %30, %33
  %35 = trunc i32 %34 to i16
  ret i16 %35
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
