; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/target-allocation-guard/ir/signed_delta_pair.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_delta_pair.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local signext i16 @signed_delta_pair(i8 noundef signext %0, i8 noundef signext %1) #0 {
  %.narrow = alloca [2 x i8], align 2
  %3 = sext i8 %0 to i16
  %.narrow8 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow9 = trunc i16 %3 to i8
  store i8 %.narrow9, ptr %.narrow8, align 2
  %4 = sext i8 %1 to i16
  %.narrow6 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow7 = trunc i16 %4 to i8
  store i8 %.narrow7, ptr %.narrow6, align 2
  %.narrow3 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 0
  %.narrow4 = load i8, ptr %.narrow3, align 2
  %.wide5 = sext i8 %.narrow4 to i16
  %5 = sext i16 %.wide5 to i32
  %.narrow1 = getelementptr inbounds [2 x i8], ptr %.narrow, i64 0, i64 1
  %.narrow2 = load i8, ptr %.narrow1, align 2
  %.wide = sext i8 %.narrow2 to i16
  %6 = sext i16 %.wide to i32
  %7 = sub nsw i32 %5, %6
  %8 = trunc i32 %7 to i16
  ret i16 %8
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
