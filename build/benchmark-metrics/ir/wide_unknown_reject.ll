; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/wide_unknown_reject.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/wide_unknown_reject.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @wide_unknown_reject(i32 noundef %0) #0 {
  %2 = alloca [2 x i16], align 2
  %3 = add i32 %0, 1025
  %4 = trunc i32 %3 to i16
  %5 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 0
  store i16 %4, ptr %5, align 2
  %6 = xor i32 %0, 257
  %7 = trunc i32 %6 to i16
  %8 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 1
  store i16 %7, ptr %8, align 2
  %9 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 0
  %10 = load i16, ptr %9, align 2
  %11 = zext i16 %10 to i32
  %12 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 1
  %13 = load i16, ptr %12, align 2
  %14 = zext i16 %13 to i32
  %15 = add nsw i32 %11, %14
  ret i32 %15
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
