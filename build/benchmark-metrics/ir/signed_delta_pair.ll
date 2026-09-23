; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/signed_delta_pair.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_delta_pair.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_delta_pair(i8 noundef signext %0, i8 noundef signext %1) #0 {
  %3 = alloca [2 x i16], align 2
  %4 = sext i8 %0 to i16
  %5 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store i16 %4, ptr %5, align 2
  %6 = sext i8 %1 to i16
  %7 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  store i16 %6, ptr %7, align 2
  %8 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %9 = load i16, ptr %8, align 2
  %10 = sext i16 %9 to i32
  %11 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %12 = load i16, ptr %11, align 2
  %13 = sext i16 %12 to i32
  %14 = sub nsw i32 %10, %13
  %15 = trunc i32 %14 to i16
  ret i16 %15
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
