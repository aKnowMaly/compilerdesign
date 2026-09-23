; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_offsets.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_offsets.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_offsets(i8 noundef signext %0, i8 noundef signext %1, i32 noundef %2) #0 {
  %4 = alloca i8, align 1
  %5 = alloca i8, align 1
  %6 = alloca i32, align 4
  %7 = alloca [2 x i16], align 2
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
  %14 = load i16, ptr %8, align 2
  %15 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 0
  store i16 %14, ptr %15, align 2
  %16 = load i16, ptr %9, align 2
  %17 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 1
  store i16 %16, ptr %17, align 2
  %18 = load i32, ptr %6, align 4
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %20, label %24

20:                                               ; preds = %3
  %21 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 0
  %22 = load i16, ptr %21, align 2
  %23 = sext i16 %22 to i32
  br label %28

24:                                               ; preds = %3
  %25 = getelementptr inbounds [2 x i16], ptr %7, i64 0, i64 1
  %26 = load i16, ptr %25, align 2
  %27 = sext i16 %26 to i32
  br label %28

28:                                               ; preds = %24, %20
  %29 = phi i32 [ %23, %20 ], [ %27, %24 ]
  %30 = trunc i32 %29 to i16
  ret i16 %30
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
