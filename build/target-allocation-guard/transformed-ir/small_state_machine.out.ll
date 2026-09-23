; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/small_state_machine.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/small_state_machine.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @small_state_machine(i32 noundef %0, i32 noundef %1) #0 {
  %.narrow = alloca [3 x i3], align 2
  %3 = and i32 %0, 7
  %4 = trunc i32 %3 to i16
  %.narrow13 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 0
  %.narrow14 = trunc i16 %4 to i3
  store i3 %.narrow14, ptr %.narrow13, align 2
  %5 = and i32 %1, 3
  %6 = trunc i32 %5 to i16
  %.narrow11 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 1
  %.narrow12 = trunc i16 %6 to i3
  store i3 %.narrow12, ptr %.narrow11, align 2
  %.narrow8 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 0
  %.narrow9 = load i3, ptr %.narrow8, align 2
  %.wide10 = zext i3 %.narrow9 to i16
  %7 = zext i16 %.wide10 to i32
  %.narrow5 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 1
  %.narrow6 = load i3, ptr %.narrow5, align 2
  %.wide7 = zext i3 %.narrow6 to i16
  %8 = zext i16 %.wide7 to i32
  %9 = or i32 %7, %8
  %10 = and i32 %9, 7
  %11 = trunc i32 %10 to i16
  %.narrow3 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 2
  %.narrow4 = trunc i16 %11 to i3
  store i3 %.narrow4, ptr %.narrow3, align 2
  %.narrow1 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 2
  %.narrow2 = load i3, ptr %.narrow1, align 2
  %.wide = zext i3 %.narrow2 to i16
  %12 = zext i16 %.wide to i32
  ret i32 %12
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
