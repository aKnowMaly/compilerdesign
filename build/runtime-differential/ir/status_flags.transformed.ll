; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/ir/status_flags.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/status_flags.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @status_flags(i32 noundef %0) #0 {
  %.narrow = alloca [3 x i3], align 2
  %2 = and i32 %0, 1
  %3 = trunc i32 %2 to i16
  %.narrow13 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 0
  %.narrow14 = trunc i16 %3 to i3
  store i3 %.narrow14, ptr %.narrow13, align 2
  %4 = lshr i32 %0, 1
  %5 = and i32 %4, 3
  %6 = trunc i32 %5 to i16
  %.narrow11 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 1
  %.narrow12 = trunc i16 %6 to i3
  store i3 %.narrow12, ptr %.narrow11, align 2
  %7 = lshr i32 %0, 3
  %8 = and i32 %7, 7
  %9 = trunc i32 %8 to i16
  %.narrow9 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 2
  %.narrow10 = trunc i16 %9 to i3
  store i3 %.narrow10, ptr %.narrow9, align 2
  %.narrow6 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 0
  %.narrow7 = load i3, ptr %.narrow6, align 2
  %.wide8 = zext i3 %.narrow7 to i16
  %10 = zext i16 %.wide8 to i32
  %.narrow3 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 1
  %.narrow4 = load i3, ptr %.narrow3, align 2
  %.wide5 = zext i3 %.narrow4 to i16
  %11 = zext i16 %.wide5 to i32
  %12 = shl i32 %11, 1
  %13 = or i32 %10, %12
  %.narrow1 = getelementptr inbounds [3 x i3], ptr %.narrow, i64 0, i64 2
  %.narrow2 = load i3, ptr %.narrow1, align 2
  %.wide = zext i3 %.narrow2 to i16
  %14 = zext i16 %.wide to i32
  %15 = shl i32 %14, 3
  %16 = or i32 %13, %15
  ret i32 %16
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %10, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %8, %10 ]
  %.0 = phi i32 [ 0, %0 ], [ %11, %10 ]
  %2 = icmp ult i32 %.0, 128
  br i1 %2, label %3, label %12

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = call i32 @status_flags(i32 noundef %.0)
  %6 = zext i32 %5 to i64
  %7 = xor i64 %.01, %6
  %8 = mul i64 %7, 1099511628211
  br label %9

9:                                                ; preds = %4
  br label %10

10:                                               ; preds = %9
  %11 = add i32 %.0, 3
  br label %1, !llvm.loop !6

12:                                               ; preds = %1
  %13 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
