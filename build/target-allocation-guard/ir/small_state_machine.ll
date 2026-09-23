; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/small_state_machine.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/small_state_machine.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @small_state_machine(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca [3 x i16], align 2
  %4 = and i32 %0, 7
  %5 = trunc i32 %4 to i16
  %6 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  store i16 %5, ptr %6, align 2
  %7 = and i32 %1, 3
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  store i16 %8, ptr %9, align 2
  %10 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  %11 = load i16, ptr %10, align 2
  %12 = zext i16 %11 to i32
  %13 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  %14 = load i16, ptr %13, align 2
  %15 = zext i16 %14 to i32
  %16 = or i32 %12, %15
  %17 = and i32 %16, 7
  %18 = trunc i32 %17 to i16
  %19 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 2
  store i16 %18, ptr %19, align 2
  %20 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 2
  %21 = load i16, ptr %20, align 2
  %22 = zext i16 %21 to i32
  ret i32 %22
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
