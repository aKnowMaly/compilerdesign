; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/packet_flags.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/packet_flags.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @packet_flags(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca [4 x i16], align 2
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %6 = load i32, ptr %3, align 4
  %7 = and i32 %6, 3
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  store i16 %8, ptr %9, align 2
  %10 = load i32, ptr %3, align 4
  %11 = lshr i32 %10, 2
  %12 = and i32 %11, 7
  %13 = trunc i32 %12 to i16
  %14 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  store i16 %13, ptr %14, align 2
  %15 = load i32, ptr %4, align 4
  %16 = and i32 %15, 15
  %17 = trunc i32 %16 to i16
  %18 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  store i16 %17, ptr %18, align 2
  %19 = load i32, ptr %4, align 4
  %20 = lshr i32 %19, 4
  %21 = and i32 %20, 31
  %22 = trunc i32 %21 to i16
  %23 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  store i16 %22, ptr %23, align 2
  %24 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  %25 = load i16, ptr %24, align 2
  %26 = zext i16 %25 to i32
  %27 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  %28 = load i16, ptr %27, align 2
  %29 = zext i16 %28 to i32
  %30 = add nsw i32 %26, %29
  %31 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  %32 = load i16, ptr %31, align 2
  %33 = zext i16 %32 to i32
  %34 = add nsw i32 %30, %33
  %35 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  %36 = load i16, ptr %35, align 2
  %37 = zext i16 %36 to i32
  %38 = add nsw i32 %34, %37
  ret i32 %38
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
