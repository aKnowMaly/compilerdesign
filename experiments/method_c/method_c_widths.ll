target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@nine_bit_values = internal global [4 x i32] zeroinitializer, align 16

define i32 @alloca_five(i16 %x) {
entry:
  %arr = alloca [2 x i16], align 2
  %masked = and i16 %x, 31
  %slot = getelementptr [2 x i16], ptr %arr, i64 0, i64 1
  store i16 %masked, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  %wide = zext i16 %loaded to i32
  ret i32 %wide
}

define void @set_nine(i32 %x, i64 %index) {
entry:
  %masked = and i32 %x, 511
  %slot = getelementptr [4 x i32], ptr @nine_bit_values, i64 0, i64 %index
  store i32 %masked, ptr %slot, align 4
  ret void
}

define i32 @get_nine(i64 %index) {
entry:
  %slot = getelementptr [4 x i32], ptr @nine_bit_values, i64 0, i64 %index
  %loaded = load i32, ptr %slot, align 4
  ret i32 %loaded
}

; METHODC: @nine_bit_values.narrow = internal global [4 x i16]
; METHODC: %arr.narrow = alloca [2 x i8]
; METHODC: store i8
; METHODC: load i8

