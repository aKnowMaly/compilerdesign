; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/ir/alpha_blend_weights.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/alpha_blend_weights.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @alpha_blend_weights(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca [3 x i16], align 2
  %5 = and i32 %0, 255
  %6 = trunc i32 %5 to i16
  %7 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 0
  store i16 %6, ptr %7, align 2
  %8 = and i32 %1, 255
  %9 = trunc i32 %8 to i16
  %10 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 1
  store i16 %9, ptr %10, align 2
  %11 = and i32 %2, 255
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 2
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 0
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 1
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  %20 = mul nsw i32 %16, %19
  %21 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 0
  %22 = load i16, ptr %21, align 2
  %23 = zext i16 %22 to i32
  %24 = sub i32 255, %23
  %25 = getelementptr inbounds [3 x i16], ptr %4, i64 0, i64 2
  %26 = load i16, ptr %25, align 2
  %27 = zext i16 %26 to i32
  %28 = mul i32 %24, %27
  %29 = add i32 %20, %28
  %30 = lshr i32 %29, 8
  ret i32 %30
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %13, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %11, %13 ]
  %.0 = phi i32 [ 0, %0 ], [ %14, %13 ]
  %2 = icmp ult i32 %.0, 128
  br i1 %2, label %3, label %15

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = mul i32 %.0, 3
  %6 = mul i32 %.0, 17
  %7 = mul i32 %.0, 29
  %8 = call i32 @alpha_blend_weights(i32 noundef %5, i32 noundef %6, i32 noundef %7)
  %9 = zext i32 %8 to i64
  %10 = xor i64 %.01, %9
  %11 = mul i64 %10, 1099511628211
  br label %12

12:                                               ; preds = %4
  br label %13

13:                                               ; preds = %12
  %14 = add i32 %.0, 5
  br label %1, !llvm.loop !6

15:                                               ; preds = %1
  %16 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
