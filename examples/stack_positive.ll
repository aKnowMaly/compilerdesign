define i16 @stack_positive(i32 %x) {
entry:
  %values = alloca [2 x i16], align 2
  %slot = getelementptr inbounds [2 x i16], ptr %values, i32 0, i32 0
  %trunc = trunc i32 %x to i16
  %masked = and i16 %trunc, 31
  store i16 %masked, ptr %slot, align 2
  %loaded = load i16, ptr %slot, align 2
  ret i16 %loaded
}
