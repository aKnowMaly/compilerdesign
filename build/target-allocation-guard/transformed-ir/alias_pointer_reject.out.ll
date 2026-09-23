; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/alias_pointer_reject.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/alias_pointer_reject.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @alias_pointer_reject(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca [2 x i16], align 2
  %4 = icmp ne i32 %1, 0
  br i1 %4, label %5, label %7

5:                                                ; preds = %2
  %6 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 1
  br label %9

7:                                                ; preds = %2
  %8 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 0
  br label %9

9:                                                ; preds = %7, %5
  %10 = phi ptr [ %6, %5 ], [ %8, %7 ]
  %11 = and i32 %0, 31
  %12 = trunc i32 %11 to i16
  store i16 %12, ptr %10, align 2
  %13 = icmp ne i32 %1, 0
  %14 = zext i1 %13 to i64
  %15 = select i1 %13, i32 1, i32 0
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds [2 x i16], ptr %3, i64 0, i64 %16
  %18 = load i16, ptr %17, align 2
  %19 = zext i16 %18 to i32
  ret i32 %19
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
