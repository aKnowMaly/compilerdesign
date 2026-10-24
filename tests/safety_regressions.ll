target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

; CHECK-LABEL: define i32 @nested_extensions
; CHECK: %a.narrow = alloca [2 x i16]
; CHECK: zext i16 {{.*}} to i32
define i32 @nested_extensions(i8 %x) {
  %a = alloca [2 x i32], align 4
  %p = getelementptr [2 x i32], ptr %a, i64 0, i64 1
  %s = sext i8 %x to i16
  %z = zext i16 %s to i32
  store i32 %z, ptr %p, align 4
  %v = load i32, ptr %p, align 4
  ret i32 %v
}

; CHECK-LABEL: define i16 @second_element
; CHECK: %a.narrow = alloca [2 x i5]
; CHECK: store i5 {{.*}}, ptr {{.*}}, align 1
; CHECK: load i5, ptr {{.*}}, align 1
; NATIVE-LABEL: define i16 @second_element
; NATIVE: %a.narrow = alloca [2 x i8]
; NATIVE: store i8 {{.*}}, ptr {{.*}}, align 1
; NATIVE: load i8, ptr {{.*}}, align 1
define i16 @second_element(i16 %x) {
  %a = alloca [2 x i16], align 2
  %p = getelementptr [2 x i16], ptr %a, i64 0, i64 1
  %m = and i16 %x, 31
  store i16 %m, ptr %p, align 2
  %v = load i16, ptr %p, align 2
  ret i16 %v
}

; CHECK-LABEL: define i16 @byte_gep
; CHECK: %a = alloca [2 x i16]
; CHECK-NOT: alloca [2 x i5]
define i16 @byte_gep(i16 %x) {
  %a = alloca [2 x i16], align 2
  %p = getelementptr i8, ptr %a, i64 2
  %m = and i16 %x, 31
  store i16 %m, ptr %p, align 2
  %v = load i16, ptr %p, align 2
  ret i16 %v
}

; CHECK-LABEL: define i16 @struct_gep
; CHECK: %a = alloca [2 x i16]
define i16 @struct_gep(i16 %x) {
  %a = alloca [2 x i16], align 2
  %p = getelementptr {i16, i16}, ptr %a, i64 0, i32 1
  %m = and i16 %x, 31
  store i16 %m, ptr %p, align 2
  %v = load i16, ptr %p, align 2
  ret i16 %v
}

; CHECK-LABEL: define i16 @dynamic_count
; CHECK: %a = alloca [2 x i16], i64 %n
define i16 @dynamic_count(i64 %n, i16 %x) {
  %a = alloca [2 x i16], i64 %n, align 2
  %p = getelementptr [2 x i16], ptr %a, i64 0, i64 1
  %m = and i16 %x, 31
  store i16 %m, ptr %p, align 2
  %v = load i16, ptr %p, align 2
  ret i16 %v
}
