; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/volatile_reject.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/volatile_reject.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @volatile_reject(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [2 x i16], align 2
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = and i32 %4, 31
  %6 = trunc i32 %5 to i16
  %7 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store volatile i16 %6, ptr %7, align 2
  %8 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %9 = load volatile i16, ptr %8, align 2
  %10 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  store volatile i16 %9, ptr %10, align 2
  %11 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %12 = load volatile i16, ptr %11, align 2
  %13 = zext i16 %12 to i32
  ret i32 %13
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
