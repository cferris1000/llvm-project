; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: sed 's/iXLen/i32/g' %s | llc -mtriple=riscv32 -mattr=+v,+xandesvbfhcvt \
; RUN:   -verify-machineinstrs -target-abi=ilp32d | FileCheck %s
; RUN: sed 's/iXLen/i64/g' %s | llc -mtriple=riscv64 -mattr=+v,+xandesvbfhcvt \
; RUN:   -verify-machineinstrs -target-abi=lp64d | FileCheck %s

define <vscale x 1 x float> @intrinsic_vfwcvt_s.bf16_nxv1f32_nxv1bf16(<vscale x 1 x bfloat> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfwcvt_s.bf16_nxv1f32_nxv1bf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, mf4, ta, ma
; CHECK-NEXT:    nds.vfwcvt.s.bf16 v9, v8
; CHECK-NEXT:    vmv1r.v v8, v9
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 1 x float> @llvm.riscv.nds.vfwcvt.s.bf16.nxv1f32.nxv1bf16(
    <vscale x 1 x float> poison,
    <vscale x 1 x bfloat> %0,
    iXLen %1)

  ret <vscale x 1 x float> %a
}

define <vscale x 2 x float> @intrinsic_vfwcvt_s.bf16_nxv2f32_nxv2bf16(<vscale x 2 x bfloat> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfwcvt_s.bf16_nxv2f32_nxv2bf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, mf2, ta, ma
; CHECK-NEXT:    nds.vfwcvt.s.bf16 v9, v8
; CHECK-NEXT:    vmv1r.v v8, v9
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.nds.vfwcvt.s.bf16.nxv2f32.nxv2bf16(
    <vscale x 2 x float> poison,
    <vscale x 2 x bfloat> %0,
    iXLen %1)

  ret <vscale x 2 x float> %a
}

define <vscale x 4 x float> @intrinsic_vfwcvt_s.bf16_nxv4f32_nxv4bf16(<vscale x 4 x bfloat> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfwcvt_s.bf16_nxv4f32_nxv4bf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, m1, ta, ma
; CHECK-NEXT:    vmv1r.v v10, v8
; CHECK-NEXT:    nds.vfwcvt.s.bf16 v8, v10
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 4 x float> @llvm.riscv.nds.vfwcvt.s.bf16.nxv4f32.nxv4bf16(
    <vscale x 4 x float> poison,
    <vscale x 4 x bfloat> %0,
    iXLen %1)

  ret <vscale x 4 x float> %a
}

define <vscale x 8 x float> @intrinsic_vfwcvt_s.bf16_nxv8f32_nxv8bf16(<vscale x 8 x bfloat> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfwcvt_s.bf16_nxv8f32_nxv8bf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, m2, ta, ma
; CHECK-NEXT:    vmv2r.v v12, v8
; CHECK-NEXT:    nds.vfwcvt.s.bf16 v8, v12
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 8 x float> @llvm.riscv.nds.vfwcvt.s.bf16.nxv8f32.nxv8bf16(
    <vscale x 8 x float> poison,
    <vscale x 8 x bfloat> %0,
    iXLen %1)

  ret <vscale x 8 x float> %a
}

define <vscale x 16 x float> @intrinsic_vfwcvt_s.bf16_nxv16f32_nxv16bf16(<vscale x 16 x bfloat> %0, iXLen %1) nounwind {
; CHECK-LABEL: intrinsic_vfwcvt_s.bf16_nxv16f32_nxv16bf16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli zero, a0, e16, m4, ta, ma
; CHECK-NEXT:    vmv4r.v v16, v8
; CHECK-NEXT:    nds.vfwcvt.s.bf16 v8, v16
; CHECK-NEXT:    ret
entry:
  %a = call <vscale x 16 x float> @llvm.riscv.nds.vfwcvt.s.bf16.nxv16f32.nxv16bf16(
    <vscale x 16 x float> poison,
    <vscale x 16 x bfloat> %0,
    iXLen %1)

  ret <vscale x 16 x float> %a
}
