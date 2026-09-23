; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/checksum_nibbles.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/checksum_nibbles.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @checksum_nibbles(i32 noundef %0) #0 {
  %2 = alloca [4 x i16], align 2
  %3 = and i32 %0, 15
  %4 = trunc i32 %3 to i16
  %5 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 0
  store i16 %4, ptr %5, align 2
  %6 = lshr i32 %0, 4
  %7 = and i32 %6, 15
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 1
  store i16 %8, ptr %9, align 2
  %10 = lshr i32 %0, 8
  %11 = and i32 %10, 15
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 2
  store i16 %12, ptr %13, align 2
  %14 = lshr i32 %0, 12
  %15 = and i32 %14, 15
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 3
  store i16 %16, ptr %17, align 2
  %18 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 0
  %19 = load i16, ptr %18, align 2
  %20 = zext i16 %19 to i32
  %21 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 1
  %22 = load i16, ptr %21, align 2
  %23 = zext i16 %22 to i32
  %24 = add nsw i32 %20, %23
  %25 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 2
  %26 = load i16, ptr %25, align 2
  %27 = zext i16 %26 to i32
  %28 = add nsw i32 %24, %27
  %29 = getelementptr inbounds [4 x i16], ptr %2, i64 0, i64 3
  %30 = load i16, ptr %29, align 2
  %31 = zext i16 %30 to i32
  %32 = add nsw i32 %28, %31
  ret i32 %32
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %11, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %9, %11 ]
  %.0 = phi i32 [ 0, %0 ], [ %12, %11 ]
  %2 = icmp ult i32 %.0, 256
  br i1 %2, label %3, label %13

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = mul i32 %.0, 4369
  %6 = call i32 @checksum_nibbles(i32 noundef %5)
  %7 = zext i32 %6 to i64
  %8 = xor i64 %.01, %7
  %9 = mul i64 %8, 1099511628211
  br label %10

10:                                               ; preds = %4
  br label %11

11:                                               ; preds = %10
  %12 = add i32 %.0, 7
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
