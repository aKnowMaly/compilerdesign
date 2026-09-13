; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem -verify-each -S %s | FileCheck-18 %s
; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem -verify-each -disable-output %s 2>&1 | FileCheck-18 %s --check-prefix=LOG

; LOG: [adaptive-width-mem] summary candidate-globals=0 candidate-allocas=6 safe=6 blocked=0 unknown-width=0 no-meaningful-reduction=0 rewrite-blocked=0 transformed-globals=0 transformed-allocas=6 loads-rewritten=5 stores-rewritten=6 bits-saved-per-element=59

define i16 @or_select_phi(i32 %x, i1 %cond) {
; CHECK-LABEL: define i16 @or_select_phi
; CHECK: %or_arr.narrow = alloca [2 x i6]
; CHECK: %select_arr.narrow = alloca [2 x i5]
; CHECK: %phi_arr.narrow = alloca [2 x i5]
; CHECK: %knownbits_arr.narrow = alloca [2 x i8]
; CHECK: %cycle_arr.narrow = alloca [2 x i6]
; CHECK: %or_loaded.narrow = load i6
; CHECK: %or_loaded.wide = zext i6 %or_loaded.narrow to i16
; CHECK: %select_loaded.narrow = load i5
; CHECK: %select_loaded.wide = zext i5 %select_loaded.narrow to i16
; CHECK: %phi_loaded.narrow = load i5
; CHECK: %phi_loaded.wide = zext i5 %phi_loaded.narrow to i16
; CHECK: %knownbits_loaded.narrow = load i8
; CHECK: %knownbits_loaded.wide = zext i8 %knownbits_loaded.narrow to i16
; CHECK: %sum1 = add i16 %or_loaded.wide, %select_loaded.wide
; CHECK: %sum2 = add i16 %sum1, %phi_loaded.wide
; CHECK: %sum3 = add i16 %sum2, %knownbits_loaded.wide
entry:
  %or_arr = alloca [2 x i16], align 2
  %select_arr = alloca [2 x i16], align 2
  %phi_arr = alloca [2 x i16], align 2
  %knownbits_arr = alloca [2 x i16], align 2
  %cycle_arr = alloca [2 x i16], align 2
  %or_slot = getelementptr inbounds [2 x i16], ptr %or_arr, i32 0, i32 0
  %select_slot = getelementptr inbounds [2 x i16], ptr %select_arr, i32 0, i32 0
  %phi_slot = getelementptr inbounds [2 x i16], ptr %phi_arr, i32 0, i32 0
  %knownbits_slot = getelementptr inbounds [2 x i16], ptr %knownbits_arr, i32 0, i32 0
  %cycle_slot = getelementptr inbounds [2 x i16], ptr %cycle_arr, i32 0, i32 0
  %trunc = trunc i32 %x to i16
  %masked_a = and i16 %trunc, 31
  %masked_b = and i16 %trunc, 48
  %or_value = or i16 %masked_a, %masked_b
  %knownbits_value = lshr i16 %trunc, 8
  %select_value = select i1 %cond, i16 %masked_a, i16 7
  br i1 %cond, label %then, label %else

then:
  br label %merge

else:
  br label %merge

merge:
  %phi_value = phi i16 [ %masked_a, %then ], [ 3, %else ]
  %unknown = add i16 %masked_a, 1
  store i16 %or_value, ptr %or_slot, align 2
  store i16 %select_value, ptr %select_slot, align 2
  store i16 %phi_value, ptr %phi_slot, align 2
  store i16 %knownbits_value, ptr %knownbits_slot, align 2
  store i16 %unknown, ptr %cycle_slot, align 2
  %or_loaded = load i16, ptr %or_slot, align 2
  %select_loaded = load i16, ptr %select_slot, align 2
  %phi_loaded = load i16, ptr %phi_slot, align 2
  %knownbits_loaded = load i16, ptr %knownbits_slot, align 2
  %sum1 = add i16 %or_loaded, %select_loaded
  %sum2 = add i16 %sum1, %phi_loaded
  %sum3 = add i16 %sum2, %knownbits_loaded
  ret i16 %sum3
}

define i16 @trunc_after_wide_mask(i32 %x) {
; CHECK-LABEL: define i16 @trunc_after_wide_mask
; CHECK: %wide_mask_arr.narrow = alloca [2 x i7]
; CHECK: %wide_masked.narrow = trunc i16 %wide_masked to i7
; CHECK: %loaded.narrow = load i7
; CHECK: %loaded.wide = zext i7 %loaded.narrow to i16
; CHECK: ret i16 %loaded.wide
entry:
  %wide_mask_arr = alloca [2 x i16], align 2
  %slot = getelementptr inbounds [2 x i16], ptr %wide_mask_arr, i32 0, i32 0
  %masked32 = and i32 %x, 127
  %wide_masked = trunc i32 %masked32 to i16
  store i16 %wide_masked, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  ret i16 %loaded
}
