; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/global_flag_table.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/global_flag_table.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@flags_a = internal global i16 1, align 2
@flags_b = internal global i16 2, align 2
@flags_c = internal global i16 4, align 2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @global_flag_table(i32 noundef %0) #0 {
  %2 = and i32 %0, 1
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %4, label %7

4:                                                ; preds = %1
  %5 = load i16, ptr @flags_a, align 2
  %6 = zext i16 %5 to i32
  br label %8

7:                                                ; preds = %1
  br label %8

8:                                                ; preds = %7, %4
  %9 = phi i32 [ %6, %4 ], [ 0, %7 ]
  %10 = and i32 %0, 2
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %12, label %15

12:                                               ; preds = %8
  %13 = load i16, ptr @flags_b, align 2
  %14 = zext i16 %13 to i32
  br label %16

15:                                               ; preds = %8
  br label %16

16:                                               ; preds = %15, %12
  %17 = phi i32 [ %14, %12 ], [ 0, %15 ]
  %18 = or i32 %9, %17
  %19 = and i32 %0, 4
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %21, label %24

21:                                               ; preds = %16
  %22 = load i16, ptr @flags_c, align 2
  %23 = zext i16 %22 to i32
  br label %25

24:                                               ; preds = %16
  br label %25

25:                                               ; preds = %24, %21
  %26 = phi i32 [ %23, %21 ], [ 0, %24 ]
  %27 = or i32 %18, %26
  ret i32 %27
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
