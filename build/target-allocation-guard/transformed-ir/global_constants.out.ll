; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/global_constants.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/global_constants.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@lut_a.narrow = internal global i3 -3, align 2
@lut_b.narrow = internal global i4 -4, align 2
@lut_c = internal global [2 x i16] [i16 3, i16 9], align 2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @global_constants() #0 {
  %.narrow = load i3, ptr @lut_a.narrow, align 2
  %.wide = zext i3 %.narrow to i16
  %1 = zext i16 %.wide to i32
  %.narrow1 = load i4, ptr @lut_b.narrow, align 2
  %.wide2 = zext i4 %.narrow1 to i16
  %2 = zext i16 %.wide2 to i32
  %3 = add nsw i32 %1, %2
  %4 = load i16, ptr @lut_c, align 2
  %5 = zext i16 %4 to i32
  %6 = add nsw i32 %3, %5
  %7 = load i16, ptr getelementptr inbounds ([2 x i16], ptr @lut_c, i64 0, i64 1), align 2
  %8 = zext i16 %7 to i32
  %9 = add nsw i32 %6, %8
  ret i32 %9
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
