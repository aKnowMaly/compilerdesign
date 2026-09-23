; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/moving_average4.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/moving_average4.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @moving_average4(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  %5 = alloca [4 x i16], align 2
  %6 = and i32 %0, 1023
  %7 = trunc i32 %6 to i16
  %8 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  store i16 %7, ptr %8, align 2
  %9 = and i32 %1, 1023
  %10 = trunc i32 %9 to i16
  %11 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  store i16 %10, ptr %11, align 2
  %12 = and i32 %2, 1023
  %13 = trunc i32 %12 to i16
  %14 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  store i16 %13, ptr %14, align 2
  %15 = and i32 %3, 1023
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  store i16 %16, ptr %17, align 2
  %18 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 0
  %19 = load i16, ptr %18, align 2
  %20 = zext i16 %19 to i32
  %21 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 1
  %22 = load i16, ptr %21, align 2
  %23 = zext i16 %22 to i32
  %24 = add nsw i32 %20, %23
  %25 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 2
  %26 = load i16, ptr %25, align 2
  %27 = zext i16 %26 to i32
  %28 = add nsw i32 %24, %27
  %29 = getelementptr inbounds [4 x i16], ptr %5, i64 0, i64 3
  %30 = load i16, ptr %29, align 2
  %31 = zext i16 %30 to i32
  %32 = add nsw i32 %28, %31
  %33 = ashr i32 %32, 2
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
