; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/tcp_flag_decode.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/tcp_flag_decode.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @tcp_flag_decode(i32 noundef %0) #0 {
  %2 = alloca [6 x i16], align 2
  %3 = lshr i32 %0, 0
  %4 = and i32 %3, 1
  %5 = trunc i32 %4 to i16
  %6 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 0
  store i16 %5, ptr %6, align 2
  %7 = lshr i32 %0, 1
  %8 = and i32 %7, 1
  %9 = trunc i32 %8 to i16
  %10 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 1
  store i16 %9, ptr %10, align 2
  %11 = lshr i32 %0, 2
  %12 = and i32 %11, 1
  %13 = trunc i32 %12 to i16
  %14 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 2
  store i16 %13, ptr %14, align 2
  %15 = lshr i32 %0, 3
  %16 = and i32 %15, 1
  %17 = trunc i32 %16 to i16
  %18 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 3
  store i16 %17, ptr %18, align 2
  %19 = lshr i32 %0, 4
  %20 = and i32 %19, 1
  %21 = trunc i32 %20 to i16
  %22 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 4
  store i16 %21, ptr %22, align 2
  %23 = lshr i32 %0, 5
  %24 = and i32 %23, 1
  %25 = trunc i32 %24 to i16
  %26 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 5
  store i16 %25, ptr %26, align 2
  %27 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 0
  %28 = load i16, ptr %27, align 2
  %29 = zext i16 %28 to i32
  %30 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 1
  %31 = load i16, ptr %30, align 2
  %32 = zext i16 %31 to i32
  %33 = mul i32 2, %32
  %34 = add i32 %29, %33
  %35 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 2
  %36 = load i16, ptr %35, align 2
  %37 = zext i16 %36 to i32
  %38 = mul i32 3, %37
  %39 = add i32 %34, %38
  %40 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 3
  %41 = load i16, ptr %40, align 2
  %42 = zext i16 %41 to i32
  %43 = mul i32 4, %42
  %44 = add i32 %39, %43
  %45 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 4
  %46 = load i16, ptr %45, align 2
  %47 = zext i16 %46 to i32
  %48 = mul i32 5, %47
  %49 = add i32 %44, %48
  %50 = getelementptr inbounds [6 x i16], ptr %2, i64 0, i64 5
  %51 = load i16, ptr %50, align 2
  %52 = zext i16 %51 to i32
  %53 = mul i32 6, %52
  %54 = add i32 %49, %53
  ret i32 %54
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
