; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/status_flags.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/status_flags.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @status_flags(i32 noundef %0) #0 {
  %2 = alloca [3 x i16], align 2
  %3 = and i32 %0, 1
  %4 = trunc i32 %3 to i16
  %5 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 0
  store i16 %4, ptr %5, align 2
  %6 = lshr i32 %0, 1
  %7 = and i32 %6, 3
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 1
  store i16 %8, ptr %9, align 2
  %10 = lshr i32 %0, 3
  %11 = and i32 %10, 7
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 2
  store i16 %12, ptr %13, align 2
  %14 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 0
  %15 = load i16, ptr %14, align 2
  %16 = zext i16 %15 to i32
  %17 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 1
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  %20 = shl i32 %19, 1
  %21 = or i32 %16, %20
  %22 = getelementptr inbounds [3 x i16], ptr %2, i64 0, i64 2
  %23 = load i16, ptr %22, align 2
  %24 = zext i16 %23 to i32
  %25 = shl i32 %24, 3
  %26 = or i32 %21, %25
  ret i32 %26
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
