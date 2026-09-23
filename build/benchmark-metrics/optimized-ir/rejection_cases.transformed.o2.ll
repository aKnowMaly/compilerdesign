; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/benchmark-metrics/transformed-ir/rejection_cases.out.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/rejection_cases.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @rejection_cases(i32 noundef %0) local_unnamed_addr #0 {
  %2 = alloca [2 x i16], align 2
  %3 = trunc i32 %0 to i16
  %4 = and i16 %3, 31
  store i16 %4, ptr %2, align 2
  call void @escape_short_array(ptr noundef nonnull %2) #2
  %5 = add i32 %0, 257
  %6 = and i32 %0, 1
  %.not = icmp eq i32 %6, 0
  %sext = shl i32 %0, 24
  %7 = ashr exact i32 %sext, 24
  %8 = and i32 %0, 255
  %9 = select i1 %.not, i32 %8, i32 %7
  %10 = load i16, ptr %2, align 2
  %11 = zext i16 %10 to i32
  %12 = and i32 %5, 65535
  %13 = and i32 %9, 65535
  %14 = add nuw nsw i32 %13, %12
  %15 = add nuw nsw i32 %14, %11
  ret i32 %15
}

declare void @escape_short_array(ptr noundef) local_unnamed_addr #1

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 18.1.8 (20ubuntu8)"}
