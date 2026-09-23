; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/rgb565_unpack.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/rgb565_unpack.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @rgb565_unpack(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [3 x i16], align 2
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = lshr i32 %4, 11
  %6 = and i32 %5, 31
  %7 = trunc i32 %6 to i16
  %8 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  store i16 %7, ptr %8, align 2
  %9 = load i32, ptr %2, align 4
  %10 = lshr i32 %9, 5
  %11 = and i32 %10, 63
  %12 = trunc i32 %11 to i16
  %13 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  store i16 %12, ptr %13, align 2
  %14 = load i32, ptr %2, align 4
  %15 = and i32 %14, 31
  %16 = trunc i32 %15 to i16
  %17 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 2
  store i16 %16, ptr %17, align 2
  %18 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 0
  %19 = load i16, ptr %18, align 2
  %20 = zext i16 %19 to i32
  %21 = mul i32 %20, 3
  %22 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 1
  %23 = load i16, ptr %22, align 2
  %24 = zext i16 %23 to i32
  %25 = mul i32 %24, 5
  %26 = add i32 %21, %25
  %27 = getelementptr inbounds [3 x i16], ptr %3, i64 0, i64 2
  %28 = load i16, ptr %27, align 2
  %29 = zext i16 %28 to i32
  %30 = mul i32 %29, 7
  %31 = add i32 %26, %30
  ret i32 %31
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

4:                                                ; preds = %17, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 65536
  br i1 %6, label %7, label %20

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = call i32 @rgb565_unpack(i32 noundef %9)
  %11 = zext i32 %10 to i64
  %12 = load i64, ptr %2, align 8
  %13 = xor i64 %12, %11
  store i64 %13, ptr %2, align 8
  %14 = load i64, ptr %2, align 8
  %15 = mul i64 %14, 1099511628211
  store i64 %15, ptr %2, align 8
  br label %16

16:                                               ; preds = %8
  br label %17

17:                                               ; preds = %16
  %18 = load i32, ptr %3, align 4
  %19 = add i32 %18, 4093
  store i32 %19, ptr %3, align 4
  br label %4, !llvm.loop !6

20:                                               ; preds = %4
  %21 = load i64, ptr %2, align 8
  %22 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %21)
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
