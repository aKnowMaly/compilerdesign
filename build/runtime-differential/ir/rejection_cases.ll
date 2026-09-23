; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/ir/rejection_cases.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/rejection_cases.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @rejection_cases(i32 noundef %0) #0 {
  %2 = alloca [2 x i16], align 2
  %3 = alloca [2 x i16], align 2
  %4 = alloca [2 x i16], align 2
  %5 = and i32 %0, 31
  %6 = trunc i32 %5 to i16
  %7 = trunc i32 %0 to i8
  %8 = trunc i32 %0 to i8
  %9 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 0
  store i16 %6, ptr %9, align 2
  %10 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 0
  call void @escape_short_array(ptr noundef %10)
  %11 = add i32 %0, 257
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store i16 %12, ptr %13, align 2
  %14 = and i32 %0, 1
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %16, label %19

16:                                               ; preds = %1
  %17 = sext i8 %7 to i16
  %18 = sext i16 %17 to i32
  br label %22

19:                                               ; preds = %1
  %20 = zext i8 %8 to i16
  %21 = zext i16 %20 to i32
  br label %22

22:                                               ; preds = %19, %16
  %23 = phi i32 [ %18, %16 ], [ %21, %19 ]
  %24 = trunc i32 %23 to i16
  %25 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  store i16 %24, ptr %25, align 2
  %26 = getelementptr inbounds [2 x i16], ptr %2, i64 0, i64 0
  %27 = load i16, ptr %26, align 2
  %28 = zext i16 %27 to i32
  %29 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %30 = load i16, ptr %29, align 2
  %31 = zext i16 %30 to i32
  %32 = add nsw i32 %28, %31
  %33 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  %34 = load i16, ptr %33, align 2
  %35 = zext i16 %34 to i32
  %36 = add nsw i32 %32, %35
  ret i32 %36
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @escape_short_array(ptr noundef %0) #0 {
  %2 = icmp ne ptr %0, null
  br i1 %2, label %3, label %10

3:                                                ; preds = %1
  %4 = getelementptr inbounds i16, ptr %0, i64 0
  %5 = load i16, ptr %4, align 2
  %6 = zext i16 %5 to i32
  %7 = xor i32 %6, 3
  %8 = trunc i32 %7 to i16
  %9 = getelementptr inbounds i16, ptr %0, i64 1
  store i16 %8, ptr %9, align 2
  br label %10

10:                                               ; preds = %3, %1
  ret void
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
  %5 = mul i32 %.0, 37
  %6 = add i32 %5, 11
  %7 = call i32 @rejection_cases(i32 noundef %6)
  %8 = zext i32 %7 to i64
  %9 = xor i64 %.01, %8
  %10 = mul i64 %9, 1099511628211
  br label %11

11:                                               ; preds = %4
  br label %12

12:                                               ; preds = %11
  %13 = add i32 %.0, 9
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
