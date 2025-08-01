; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s
; RUN: llc < %s -mtriple=i386-pc-win32 | FileCheck %s -check-prefix=CHECK-WIN

define i32 @ldexpf_not_fp(i32 %a, i32 %b) nounwind {
; CHECK-LABEL: ldexpf_not_fp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    callq ldexpf@PLT
; CHECK-NEXT:    popq %rcx
; CHECK-NEXT:    retq
;
; CHECK-WIN-LABEL: ldexpf_not_fp:
; CHECK-WIN:       # %bb.0:
; CHECK-WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; CHECK-WIN-NEXT:    pushl {{[0-9]+}}(%esp)
; CHECK-WIN-NEXT:    calll _ldexpf
; CHECK-WIN-NEXT:    addl $8, %esp
; CHECK-WIN-NEXT:    retl
  %result = call i32 @ldexpf(i32 %a, i32 %b) #0
  ret i32 %result
}

define float @ldexp_not_int(float %a, float %b) nounwind {
; CHECK-LABEL: ldexp_not_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    callq ldexp@PLT
; CHECK-NEXT:    popq %rax
; CHECK-NEXT:    retq
;
; CHECK-WIN-LABEL: ldexp_not_int:
; CHECK-WIN:       # %bb.0:
; CHECK-WIN-NEXT:    subl $8, %esp
; CHECK-WIN-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-WIN-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-WIN-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-WIN-NEXT:    fstps (%esp)
; CHECK-WIN-NEXT:    calll _ldexp
; CHECK-WIN-NEXT:    addl $8, %esp
; CHECK-WIN-NEXT:    retl
  %result = call float @ldexp(float %a, float %b) #0
  ret float %result
}

declare i32 @ldexpf(i32, i32) #0
declare float @ldexp(float, float) #0

attributes #0 = { nounwind readnone }
