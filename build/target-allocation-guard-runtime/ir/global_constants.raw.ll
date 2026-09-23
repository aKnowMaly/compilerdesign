; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/global_constants.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/global_constants.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@lut_a = internal global i16 5, align 2
@lut_b = internal global i16 12, align 2
@lut_c = internal global [2 x i16] [i16 3, i16 9], align 2
@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @global_constants() #0 {
  %1 = load i16, ptr @lut_a, align 2
  %2 = zext i16 %1 to i32
  %3 = load i16, ptr @lut_b, align 2
  %4 = zext i16 %3 to i32
  %5 = add nsw i32 %2, %4
  %6 = load i16, ptr @lut_c, align 2
  %7 = zext i16 %6 to i32
  %8 = add nsw i32 %5, %7
  %9 = load i16, ptr getelementptr inbounds ([2 x i16], ptr @lut_c, i64 0, i64 1), align 2
  %10 = zext i16 %9 to i32
  %11 = add nsw i32 %8, %10
  ret i32 %11
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i64 1469598103934665603, ptr %2, align 8
  store i32 0, ptr %3, align 4
  br label %4

4:                                                ; preds = %16, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 64
  br i1 %6, label %7, label %19

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = call i32 @global_constants()
  %10 = zext i32 %9 to i64
  %11 = load i64, ptr %2, align 8
  %12 = xor i64 %11, %10
  store i64 %12, ptr %2, align 8
  %13 = load i64, ptr %2, align 8
  %14 = mul i64 %13, 1099511628211
  store i64 %14, ptr %2, align 8
  br label %15

15:                                               ; preds = %8
  br label %16

16:                                               ; preds = %15
  %17 = load i32, ptr %3, align 4
  %18 = add i32 %17, 1
  store i32 %18, ptr %3, align 4
  br label %4, !llvm.loop !6

19:                                               ; preds = %4
  %20 = load i64, ptr %2, align 8
  %21 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %20)
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
