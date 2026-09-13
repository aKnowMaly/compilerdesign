; Experimental target-allocation guard: safety inference is unchanged, but
; allocation-neutral rewrites remain in the original representation.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

define i32 @target_allocation_guard(i16 %x) {
entry:
  %neutral = alloca [2 x i16], align 2
  %positive = alloca [2 x i16], align 2
  %neutral.slot = getelementptr inbounds [2 x i16], ptr %neutral, i32 0, i32 0
  %positive.slot = getelementptr inbounds [2 x i16], ptr %positive, i32 0, i32 0
  %neutral.value = and i16 %x, 1023
  %positive.value = and i16 %x, 255
  store i16 %neutral.value, ptr %neutral.slot, align 2
  store i16 %positive.value, ptr %positive.slot, align 2
  %neutral.load = load i16, ptr %neutral.slot, align 2
  %positive.load = load i16, ptr %positive.slot, align 2
  %neutral.wide = zext i16 %neutral.load to i32
  %positive.wide = zext i16 %positive.load to i32
  %sum = add i32 %neutral.wide, %positive.wide
  ret i32 %sum
}

; IR: %neutral = alloca [2 x i16]
; IR: %positive.narrow = alloca [2 x i8]
; IR-NOT: %neutral.narrow
; LOG: candidate=neutral reason=no-target-allocation-benefit baseline-alloc-bytes=4 transformed-alloc-bytes=4
; LOG: transform alloca name=positive.narrow original-bits=16 narrowed-bits=8
; LOG: summary candidate-globals=0 candidate-allocas=2 safe=2 blocked=0
; LOG-SAME: transformed-globals=0 transformed-allocas=1
; LOG-SAME: no-target-allocation-benefit=1
