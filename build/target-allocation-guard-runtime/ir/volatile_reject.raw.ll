; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/volatile_reject.combined.c'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard-runtime/src/volatile_reject.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @volatile_reject(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca [2 x i16], align 2
  store i32 %0, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %5 = and i32 %4, 31
  %6 = trunc i32 %5 to i16
  %7 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  store volatile i16 %6, ptr %7, align 2
  %8 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  %9 = load volatile i16, ptr %8, align 2
  %10 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  store volatile i16 %9, ptr %10, align 2
  %11 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  %12 = load volatile i16, ptr %11, align 2
  %13 = zext i16 %12 to i32
  ret i32 %13
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

4:                                                ; preds = %18, %0
  %5 = load i32, ptr %3, align 4
  %6 = icmp ult i32 %5, 128
  br i1 %6, label %7, label %21

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %7
  %9 = load i32, ptr %3, align 4
  %10 = mul i32 %9, 31
  %11 = call i32 @volatile_reject(i32 noundef %10)
  %12 = zext i32 %11 to i64
  %13 = load i64, ptr %2, align 8
  %14 = xor i64 %13, %12
  store i64 %14, ptr %2, align 8
  %15 = load i64, ptr %2, align 8
  %16 = mul i64 %15, 1099511628211
  store i64 %16, ptr %2, align 8
  br label %17

17:                                               ; preds = %8
  br label %18

18:                                               ; preds = %17
  %19 = load i32, ptr %3, align 4
  %20 = add i32 %19, 7
  store i32 %20, ptr %3, align 4
  br label %4, !llvm.loop !6

21:                                               ; preds = %4
  %22 = load i64, ptr %2, align 8
  %23 = call i32 (ptr, ...) @printf(ptr noundef @.str, i64 noundef %22)
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
