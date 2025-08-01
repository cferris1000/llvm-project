; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5

; RUN: llc < %s -disable-wasm-fallthrough-return-opt -wasm-keep-registers  -mattr=+simd128 | FileCheck %s

target triple = "wasm32-unknown-unknown"

declare <4 x float> @llvm.exp10.v4f32(<4 x float>)

define <4 x float> @exp10_f32v4(<4 x float> %v) {
; CHECK-LABEL: exp10_f32v4:
; CHECK:         .functype exp10_f32v4 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0: # %entry
; CHECK-NEXT:    local.get $push12=, 0
; CHECK-NEXT:    f32x4.extract_lane $push0=, $pop12, 0
; CHECK-NEXT:    call $push1=, exp10f, $pop0
; CHECK-NEXT:    f32x4.splat $push2=, $pop1
; CHECK-NEXT:    local.get $push13=, 0
; CHECK-NEXT:    f32x4.extract_lane $push3=, $pop13, 1
; CHECK-NEXT:    call $push4=, exp10f, $pop3
; CHECK-NEXT:    f32x4.replace_lane $push5=, $pop2, 1, $pop4
; CHECK-NEXT:    local.get $push14=, 0
; CHECK-NEXT:    f32x4.extract_lane $push6=, $pop14, 2
; CHECK-NEXT:    call $push7=, exp10f, $pop6
; CHECK-NEXT:    f32x4.replace_lane $push8=, $pop5, 2, $pop7
; CHECK-NEXT:    local.get $push15=, 0
; CHECK-NEXT:    f32x4.extract_lane $push9=, $pop15, 3
; CHECK-NEXT:    call $push10=, exp10f, $pop9
; CHECK-NEXT:    f32x4.replace_lane $push11=, $pop8, 3, $pop10
; CHECK-NEXT:    return $pop11
entry:
  %r = call <4 x float> @llvm.exp10.v4f32(<4 x float> %v)
  ret <4 x float> %r
}
