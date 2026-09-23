; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/ir/sensor_bucket.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/sensor_bucket.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @sensor_bucket(i32 noundef %0) #0 {
  %.narrow = alloca [2 x i10], align 2
  %2 = and i32 %0, 1023
  %3 = trunc i32 %2 to i16
  %.narrow8 = getelementptr inbounds [2 x i10], ptr %.narrow, i64 0, i64 0
  %.narrow9 = trunc i16 %3 to i10
  store i10 %.narrow9, ptr %.narrow8, align 2
  %.narrow5 = getelementptr inbounds [2 x i10], ptr %.narrow, i64 0, i64 0
  %.narrow6 = load i10, ptr %.narrow5, align 2
  %.wide7 = zext i10 %.narrow6 to i16
  %4 = zext i16 %.wide7 to i32
  %5 = ashr i32 %4, 5
  %6 = and i32 %5, 31
  %7 = trunc i32 %6 to i16
  %.narrow3 = getelementptr inbounds [2 x i10], ptr %.narrow, i64 0, i64 1
  %.narrow4 = trunc i16 %7 to i10
  store i10 %.narrow4, ptr %.narrow3, align 2
  %.narrow1 = getelementptr inbounds [2 x i10], ptr %.narrow, i64 0, i64 1
  %.narrow2 = load i10, ptr %.narrow1, align 2
  %.wide = zext i10 %.narrow2 to i16
  %8 = zext i16 %.wide to i32
  ret i32 %8
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %11, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %9, %11 ]
  %.0 = phi i32 [ 0, %0 ], [ %12, %11 ]
  %2 = icmp ult i32 %.0, 1024
  br i1 %2, label %3, label %13

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = mul i32 %.0, 17
  %6 = call i32 @sensor_bucket(i32 noundef %5)
  %7 = zext i32 %6 to i64
  %8 = xor i64 %.01, %7
  %9 = mul i64 %8, 1099511628211
  br label %10

10:                                               ; preds = %4
  br label %11

11:                                               ; preds = %10
  %12 = add i32 %.0, 29
  br label %1, !llvm.loop !6

13:                                               ; preds = %1
  %14 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
