; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem -verify-each -S %s | FileCheck-18 %s
; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem -verify-each -disable-output %s 2>&1 | FileCheck-18 %s --check-prefix=LOG

; LOG: [adaptive-width-mem] summary candidate-globals=4 candidate-allocas=6 safe=8 blocked=2 unknown-width=2 not-profitable=1 rewrite-blocked=0 transformed-globals=2 transformed-allocas=3 loads-rewritten=2 stores-rewritten=3 bits-saved-per-element=67

@internal_arr = internal global [4 x i32] zeroinitializer
@private_byte = private global i8 0
@small_global = internal global i32 7
@internal_escaped = internal global i32 0
@external_arr = global [4 x i32] zeroinitializer
@internal_float = internal global float 0.000000e+00

declare void @escape(ptr)

define i32 @use_stack_array(i32 %x) {
; CHECK-LABEL: define i32 @use_stack_array
; CHECK: %const_arr.narrow = alloca [2 x i4]
; CHECK: %mask_arr.narrow = alloca [2 x i5]
; CHECK: %zext_arr.narrow = alloca [2 x i8]
; CHECK: %unknown_arr = alloca [2 x i16]
; CHECK: %escaped_arr = alloca [2 x i32]
; CHECK-NOT: %const_arr = alloca [2 x i16]
; CHECK-NOT: %mask_arr = alloca [2 x i16]
; CHECK-NOT: %zext_arr = alloca [2 x i16]
entry:
  %local_arr = alloca [8 x i16], align 2
  %const_arr = alloca [2 x i16], align 2
  %mask_arr = alloca [2 x i16], align 2
  %zext_arr = alloca [2 x i16], align 2
  %unknown_arr = alloca [2 x i16], align 2
  %escaped_arr = alloca [2 x i32], align 4
  %scalar = alloca i32, align 4
  %float_arr = alloca [2 x float], align 4
  %slot = getelementptr inbounds [8 x i16], ptr %local_arr, i32 0, i32 0
  %const_slot = getelementptr inbounds [2 x i16], ptr %const_arr, i32 0, i32 0
  %mask_slot = getelementptr inbounds [2 x i16], ptr %mask_arr, i32 0, i32 0
  %zext_slot = getelementptr inbounds [2 x i16], ptr %zext_arr, i32 0, i32 0
  %unknown_slot = getelementptr inbounds [2 x i16], ptr %unknown_arr, i32 0, i32 0
  %trunc = trunc i32 %x to i16
  %masked = and i16 %trunc, 31
  %byte = trunc i32 %x to i8
  %wide_byte = zext i8 %byte to i16
  %unknown = add i16 %trunc, 1
  store i16 %trunc, ptr %slot, align 2
  store i16 15, ptr %const_slot, align 2
  store i16 %masked, ptr %mask_slot, align 2
  store i16 %wide_byte, ptr %zext_slot, align 2
  store i16 %unknown, ptr %unknown_slot, align 2
  call void @escape(ptr %escaped_arr)
  ret i32 %x
}

define i32 @use_globals(i32 %x) {
; CHECK-LABEL: define i32 @use_globals
; CHECK: %byte.narrow = load i1, ptr @private_byte.narrow
; CHECK: %byte.wide = zext i1 %byte.narrow to i8
; CHECK: %small.narrow = load i3, ptr @small_global.narrow
; CHECK: %small.wide = zext i3 %small.narrow to i32
; CHECK: call void @escape(ptr @internal_escaped)
entry:
  %slot = getelementptr inbounds [4 x i32], ptr @internal_arr, i32 0, i32 1
  store i32 %x, ptr %slot, align 4
  %loaded = load i32, ptr %slot, align 4
  %byte = load i8, ptr @private_byte, align 1
  %small = load i32, ptr @small_global, align 4
  call void @escape(ptr @internal_escaped)
  %ext = zext i8 %byte to i32
  %sum1 = add i32 %loaded, %ext
  %sum = add i32 %sum1, %small
  ret i32 %sum
}
