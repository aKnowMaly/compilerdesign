; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/protocol_version_table.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/protocol_version_table.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @protocol_version_table(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [3 x i16], align 2
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = lshr i32 %4, 29
  %6 = and i32 %5, 7
  %7 = trunc i32 %6 to i16
  %8 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  store i16 %7, ptr %8, align 2
  %9 = load i32, ptr %2, align 4
  %10 = lshr i32 %9, 24
  %11 = and i32 %10, 31
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  %20 = or i32 %16, %19
  %21 = and i32 %20, 31
  %22 = trunc i32 %21 to i16
  %23 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 2
  store i16 %22, ptr %23, align 2
  %24 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  %25 = load i16, ptr %24, align 2
  %26 = zext i16 %25 to i32
  %27 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  %28 = load i16, ptr %27, align 2
  %29 = zext i16 %28 to i32
  %30 = add nsw i32 %26, %29
  %31 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 2
  %32 = load i16, ptr %31, align 2
  %33 = zext i16 %32 to i32
  %34 = add nsw i32 %30, %33
  ret i32 %34
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
