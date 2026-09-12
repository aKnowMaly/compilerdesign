; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem-log -verify-each -S %s | FileCheck-18 %s --check-prefix=LOGONLY
; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem-allocas -verify-each -S %s | FileCheck-18 %s --check-prefix=ALLOCAS
; RUN: opt-18 -load-pass-plugin=%plugin -passes=adaptive-width-mem-globals -verify-each -S %s | FileCheck-18 %s --check-prefix=GLOBALS

@tiny = internal global i32 7

define i32 @modes(i32 %x) {
entry:
  %values = alloca [2 x i16], align 2
  %slot = getelementptr inbounds [2 x i16], ptr %values, i32 0, i32 0
  %trunc = trunc i32 %x to i16
  %masked = and i16 %trunc, 31
  store i16 %masked, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  %global = load i32, ptr @tiny, align 4
  %wide = zext i16 %loaded to i32
  %sum = add i32 %wide, %global
  ret i32 %sum
}

; LOGONLY: @tiny = internal global i32 7
; LOGONLY: %values = alloca [2 x i16]
; LOGONLY: %loaded = load i16
; LOGONLY-NOT: @tiny.narrow
; LOGONLY-NOT: %values.narrow

; ALLOCAS: @tiny = internal global i32 7
; ALLOCAS: %values.narrow = alloca [2 x i5]
; ALLOCAS: %loaded.narrow = load i5
; ALLOCAS: %loaded.wide = zext i5 %loaded.narrow to i16
; ALLOCAS-NOT: @tiny.narrow

; GLOBALS: @tiny.narrow = internal global i3 -1
; GLOBALS: %values = alloca [2 x i16]
; GLOBALS: %global.narrow = load i3, ptr @tiny.narrow
; GLOBALS: %global.wide = zext i3 %global.narrow to i32
; GLOBALS-NOT: %values.narrow
