; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/ir/ipv4_header_fields.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/ipv4_header_fields.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @ipv4_header_fields(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca [4 x i16], align 2
  %4 = lshr i32 %0, 28
  %5 = and i32 %4, 15
  %6 = trunc i32 %5 to i16
  %7 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  store i16 %6, ptr %7, align 2
  %8 = lshr i32 %0, 24
  %9 = and i32 %8, 15
  %10 = trunc i32 %9 to i16
  %11 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  store i16 %10, ptr %11, align 2
  %12 = and i32 %0, 255
  %13 = trunc i32 %12 to i16
  %14 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  store i16 %13, ptr %14, align 2
  %15 = lshr i32 %1, 16
  %16 = and i32 %15, 63
  %17 = trunc i32 %16 to i16
  %18 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  store i16 %17, ptr %18, align 2
  %19 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 0
  %20 = load i16, ptr %19, align 2
  %21 = zext i16 %20 to i32
  %22 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 1
  %23 = load i16, ptr %22, align 2
  %24 = zext i16 %23 to i32
  %25 = add nsw i32 %21, %24
  %26 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 2
  %27 = load i16, ptr %26, align 2
  %28 = zext i16 %27 to i32
  %29 = add nsw i32 %25, %28
  %30 = getelementptr inbounds [4 x i16], ptr %3, i64 0, i64 3
  %31 = load i16, ptr %30, align 2
  %32 = zext i16 %31 to i32
  %33 = add nsw i32 %29, %32
  ret i32 %33
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %12, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %10, %12 ]
  %.0 = phi i32 [ 0, %0 ], [ %13, %12 ]
  %2 = icmp ult i32 %.0, 128
  br i1 %2, label %3, label %14

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = mul i32 %.0, 19088743
  %6 = mul i32 %.0, 124076833
  %7 = call i32 @ipv4_header_fields(i32 noundef %5, i32 noundef %6)
  %8 = zext i32 %7 to i64
  %9 = xor i64 %.01, %8
  %10 = mul i64 %9, 1099511628211
  br label %11

11:                                               ; preds = %4
  br label %12

12:                                               ; preds = %11
  %13 = add i32 %.0, 7
  br label %1, !llvm.loop !6

14:                                               ; preds = %1
  %15 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %.01)
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
