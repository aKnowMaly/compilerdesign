; ModuleID = '/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/ir/global_lookup_small.ll'
source_filename = "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/build/runtime-differential/src/global_lookup_small.combined.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@small_lut = internal global [4 x i16] [i16 2, i16 4, i16 6, i16 8], align 2
@.str = private unnamed_addr constant [6 x i8] c"%llu\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @global_lookup_small(i32 noundef %0) #0 {
  %2 = and i32 %0, 3
  %3 = zext i32 %2 to i64
  %4 = getelementptr inbounds [4 x i16], ptr @small_lut, i64 0, i64 %3
  %5 = load i16, ptr %4, align 2
  %6 = zext i16 %5 to i32
  ret i32 %6
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  br label %1

1:                                                ; preds = %10, %0
  %.01 = phi i64 [ 1469598103934665603, %0 ], [ %8, %10 ]
  %.0 = phi i32 [ 0, %0 ], [ %11, %10 ]
  %2 = icmp ult i32 %.0, 64
  br i1 %2, label %3, label %12

3:                                                ; preds = %1
  br label %4

4:                                                ; preds = %3
  %5 = call i32 @global_lookup_small(i32 noundef %.0)
  %6 = zext i32 %5 to i64
  %7 = xor i64 %.01, %6
  %8 = mul i64 %7, 1099511628211
  br label %9

9:                                                ; preds = %4
  br label %10

10:                                               ; preds = %9
  %11 = add i32 %.0, 1
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
