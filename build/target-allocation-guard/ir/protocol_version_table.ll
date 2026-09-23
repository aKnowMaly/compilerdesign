; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/protocol_version_table.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/protocol_version_table.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @protocol_version_table(i32 noundef %0) #0 {
  %2 = alloca [3 x i16], align 2
  %3 = lshr i32 %0, 29
  %4 = and i32 %3, 7
  %5 = trunc i32 %4 to i16
  %6 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 0
  store i16 %5, ptr %6, align 2
  %7 = lshr i32 %0, 24
  %8 = and i32 %7, 31
  %9 = trunc i32 %8 to i16
  %10 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 1
  store i16 %9, ptr %10, align 2
  %11 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 0
  %12 = load i16, ptr %11, align 2
  %13 = zext i16 %12 to i32
  %14 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 1
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = or i32 %13, %16
  %18 = and i32 %17, 31
  %19 = trunc i32 %18 to i16
  %20 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 2
  store i16 %19, ptr %20, align 2
  %21 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 0
  %22 = load i16, ptr %21, align 2
  %23 = zext i16 %22 to i32
  %24 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 1
  %25 = load i16, ptr %24, align 2
  %26 = zext i16 %25 to i32
  %27 = add nsw i32 %23, %26
  %28 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 2
  %29 = load i16, ptr %28, align 2
  %30 = zext i16 %29 to i32
  %31 = add nsw i32 %27, %30
  ret i32 %31
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
