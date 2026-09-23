; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/global_flag_table.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/global_flag_table.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@flags_a.narrow = internal global i1 true, align 2
@flags_b.narrow = internal global i2 -2, align 2
@flags_c.narrow = internal global i3 -4, align 2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @global_flag_table(i32 noundef %0) #0 {
  %2 = and i32 %0, 1
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %4, label %6

4:                                                ; preds = %1
  %.narrow = load i1, ptr @flags_a.narrow, align 2
  %.wide = zext i1 %.narrow to i16
  %5 = zext i16 %.wide to i32
  br label %7

6:                                                ; preds = %1
  br label %7

7:                                                ; preds = %6, %4
  %8 = phi i32 [ %5, %4 ], [ 0, %6 ]
  %9 = and i32 %0, 2
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %11, label %13

11:                                               ; preds = %7
  %.narrow1 = load i2, ptr @flags_b.narrow, align 2
  %.wide2 = zext i2 %.narrow1 to i16
  %12 = zext i16 %.wide2 to i32
  br label %14

13:                                               ; preds = %7
  br label %14

14:                                               ; preds = %13, %11
  %15 = phi i32 [ %12, %11 ], [ 0, %13 ]
  %16 = or i32 %8, %15
  %17 = and i32 %0, 4
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %19, label %21

19:                                               ; preds = %14
  %.narrow3 = load i3, ptr @flags_c.narrow, align 2
  %.wide4 = zext i3 %.narrow3 to i16
  %20 = zext i16 %.wide4 to i32
  br label %22

21:                                               ; preds = %14
  br label %22

22:                                               ; preds = %21, %19
  %23 = phi i32 [ %20, %19 ], [ 0, %21 ]
  %24 = or i32 %16, %23
  ret i32 %24
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
