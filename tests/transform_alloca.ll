; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem -verify-each -S %s | FileCheck-18 %s
; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem -verify-each -disable-output %s 2>&1 | FileCheck-18 %s --check-prefix=LOG

; LOG: [adaptive-width-mem] summary candidate-globals=0 candidate-allocas=7 safe=7 blocked=0 unknown-width=2 not-profitable=0 rewrite-blocked=0 transformed-globals=0 transformed-allocas=5 loads-rewritten=2 stores-rewritten=5 bits-saved-per-element=50

define void @narrow_no_load_stack_arrays(i32 %x) {
; CHECK-LABEL: define void @narrow_no_load_stack_arrays
; CHECK: %const_arr.narrow = alloca [2 x i4]
; CHECK: %mask_arr.narrow = alloca [2 x i5]
; CHECK: %zext_arr.narrow = alloca [2 x i8]
; CHECK: %unknown_arr = alloca [2 x i16]
; CHECK-NOT: %const_arr = alloca [2 x i16]
; CHECK-NOT: %mask_arr = alloca [2 x i16]
; CHECK-NOT: %zext_arr = alloca [2 x i16]
; CHECK: store i4
; CHECK: store i5
; CHECK: store i8
entry:
  %const_arr = alloca [2 x i16], align 2
  %mask_arr = alloca [2 x i16], align 2
  %zext_arr = alloca [2 x i16], align 2
  %unknown_arr = alloca [2 x i16], align 2
  %const_slot = getelementptr inbounds [2 x i16], ptr %const_arr, i32 0, i32 0
  %mask_slot = getelementptr inbounds [2 x i16], ptr %mask_arr, i32 0, i32 0
  %zext_slot = getelementptr inbounds [2 x i16], ptr %zext_arr, i32 0, i32 0
  %unknown_slot = getelementptr inbounds [2 x i16], ptr %unknown_arr, i32 0, i32 0
  %trunc = trunc i32 %x to i16
  %masked = and i16 %trunc, 31
  %byte = trunc i32 %x to i8
  %wide_byte = zext i8 %byte to i16
  %unknown = add i16 %trunc, 1
  store i16 15, ptr %const_slot, align 2
  store i16 %masked, ptr %mask_slot, align 2
  store i16 %wide_byte, ptr %zext_slot, align 2
  store i16 %unknown, ptr %unknown_slot, align 2
  ret void
}

define i16 @narrow_loaded_stack_array(i32 %x) {
; CHECK-LABEL: define i16 @narrow_loaded_stack_array
; CHECK: %mask_arr.narrow = alloca [2 x i5]
; CHECK-NOT: %mask_arr = alloca [2 x i16]
; CHECK: %loaded.narrow = load i5
; CHECK: %loaded.wide = zext i5 %loaded.narrow to i16
; CHECK: %sum = add i16 %loaded.wide, 1
; CHECK: ret i16 %sum
entry:
  %mask_arr = alloca [2 x i16], align 2
  %slot = getelementptr inbounds [2 x i16], ptr %mask_arr, i32 0, i32 0
  %trunc = trunc i32 %x to i16
  %masked = and i16 %trunc, 31
  store i16 %masked, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  %sum = add i16 %loaded, 1
  ret i16 %sum
}

define i16 @narrow_signed_stack_array(i8 %x) {
; CHECK-LABEL: define i16 @narrow_signed_stack_array
; CHECK: %signed_arr.narrow = alloca [2 x i8]
; CHECK: %signed_value.narrow = trunc i16 %signed_value to i8
; CHECK: %loaded.narrow = load i8
; CHECK: %loaded.wide = sext i8 %loaded.narrow to i16
; CHECK: ret i16 %loaded.wide
entry:
  %signed_arr = alloca [2 x i16], align 2
  %slot = getelementptr inbounds [2 x i16], ptr %signed_arr, i32 0, i32 0
  %signed_value = sext i8 %x to i16
  store i16 %signed_value, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  ret i16 %loaded
}

define i16 @do_not_narrow_mixed_signedness(i8 %x, i1 %cond) {
; CHECK-LABEL: define i16 @do_not_narrow_mixed_signedness
; CHECK: %signed_arr = alloca [2 x i16]
; CHECK: %signed_value = sext i8 %x to i16
; CHECK: %unsigned_value = zext i8 %x to i16
; CHECK: %mixed_value = select i1 %cond, i16 %signed_value, i16 %unsigned_value
; CHECK: store i16 %mixed_value
entry:
  %signed_arr = alloca [2 x i16], align 2
  %slot = getelementptr inbounds [2 x i16], ptr %signed_arr, i32 0, i32 0
  %signed_value = sext i8 %x to i16
  %unsigned_value = zext i8 %x to i16
  %mixed_value = select i1 %cond, i16 %signed_value, i16 %unsigned_value
  store i16 %mixed_value, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  ret i16 %loaded
}
