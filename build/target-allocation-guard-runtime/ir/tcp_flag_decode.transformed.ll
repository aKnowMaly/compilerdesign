; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/tcp_flag_decode.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/tcp_flag_decode.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @tcp_flag_decode(i32 noundef %0) #0 {
  %.narrow = alloca [6 x i1], align 2
  %2 = lshr i32 %0, 0
  %3 = and i32 %2, 1
  %4 = trunc i32 %3 to i16
  %.narrow28 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 0
  %.narrow29 = trunc i16 %4 to i1
  store i1 %.narrow29, ptr %.narrow28, align 2
  %5 = lshr i32 %0, 1
  %6 = and i32 %5, 1
  %7 = trunc i32 %6 to i16
  %.narrow26 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 1
  %.narrow27 = trunc i16 %7 to i1
  store i1 %.narrow27, ptr %.narrow26, align 2
  %8 = lshr i32 %0, 2
  %9 = and i32 %8, 1
  %10 = trunc i32 %9 to i16
  %.narrow24 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 2
  %.narrow25 = trunc i16 %10 to i1
  store i1 %.narrow25, ptr %.narrow24, align 2
  %11 = lshr i32 %0, 3
  %12 = and i32 %11, 1
  %13 = trunc i32 %12 to i16
  %.narrow22 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 3
  %.narrow23 = trunc i16 %13 to i1
  store i1 %.narrow23, ptr %.narrow22, align 2
  %14 = lshr i32 %0, 4
  %15 = and i32 %14, 1
  %16 = trunc i32 %15 to i16
  %.narrow20 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 4
  %.narrow21 = trunc i16 %16 to i1
  store i1 %.narrow21, ptr %.narrow20, align 2
  %17 = lshr i32 %0, 5
  %18 = and i32 %17, 1
  %19 = trunc i32 %18 to i16
  %.narrow18 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 5
  %.narrow19 = trunc i16 %19 to i1
  store i1 %.narrow19, ptr %.narrow18, align 2
  %.narrow15 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 0
  %.narrow16 = load i1, ptr %.narrow15, align 2
  %.wide17 = zext i1 %.narrow16 to i16
  %20 = zext i16 %.wide17 to i32
  %.narrow12 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 1
  %.narrow13 = load i1, ptr %.narrow12, align 2
  %.wide14 = zext i1 %.narrow13 to i16
  %21 = zext i16 %.wide14 to i32
  %22 = mul i32 2, %21
  %23 = add i32 %20, %22
  %.narrow9 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 2
  %.narrow10 = load i1, ptr %.narrow9, align 2
  %.wide11 = zext i1 %.narrow10 to i16
  %24 = zext i16 %.wide11 to i32
  %25 = mul i32 3, %24
  %26 = add i32 %23, %25
  %.narrow6 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 3
  %.narrow7 = load i1, ptr %.narrow6, align 2
  %.wide8 = zext i1 %.narrow7 to i16
  %27 = zext i16 %.wide8 to i32
  %28 = mul i32 4, %27
  %29 = add i32 %26, %28
  %.narrow3 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 4
  %.narrow4 = load i1, ptr %.narrow3, align 2
  %.wide5 = zext i1 %.narrow4 to i16
  %30 = zext i16 %.wide5 to i32
  %31 = mul i32 5, %30
  %32 = add i32 %29, %31
  %.narrow1 = getelementptr inbounds [6 x i1], ptr %.narrow, i64 0, i64 5
  %.narrow2 = load i1, ptr %.narrow1, align 2
  %.wide = zext i1 %.narrow2 to i16
  %33 = zext i16 %.wide to i32
  %34 = mul i32 6, %33
  %35 = add i32 %32, %34
  ret i32 %35
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
  %5 = call i32 @tcp_flag_decode(i32 noundef %.0)
  %6 = zext i32 %5 to i64
  %7 = xor i64 %.01, %6
  %8 = mul i64 %7, 1099511628211
  br label %9

9:                                                ; preds = %4
  br label %10

10:                                               ; preds = %9
  %11 = add i32 %.0, 5
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
