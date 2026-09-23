; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/ir/signed_offsets.raw.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_offsets.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_offsets(i8 noundef signext %0, i8 noundef signext %1, i32 noundef %2) #0 {
  %4 = alloca [2 x i16], align 2
  %5 = sext i8 %0 to i16
  %6 = sext i8 %1 to i16
  %7 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  store i16 %5, ptr %7, align 2
  %8 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 1
  store i16 %6, ptr %8, align 2
  %9 = icmp ne i32 %2, 0
  br i1 %9, label %10, label %14

10:                                               ; preds = %3
  %11 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 0
  %12 = load i16, ptr %11, align 2
  %13 = sext i16 %12 to i32
  br label %18

14:                                               ; preds = %3
  %15 = getelementptr inbounds [2 x i16], ptr %4, i64 0, i64 1
  %16 = load i16, ptr %15, align 2
  %17 = sext i16 %16 to i32
  br label %18

18:                                               ; preds = %14, %10
  %19 = phi i32 [ %13, %10 ], [ %17, %14 ]
  %20 = trunc i32 %19 to i16
  ret i16 %20
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
