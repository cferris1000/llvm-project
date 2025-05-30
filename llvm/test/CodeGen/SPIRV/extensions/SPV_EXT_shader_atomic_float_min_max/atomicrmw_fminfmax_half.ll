; RUN: not llc -O0 -mtriple=spirv32-unknown-unknown %s -o %t.spvt 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR

; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown --spirv-ext=+SPV_EXT_shader_atomic_float_min_max %s -o - | FileCheck %s

; CHECK-ERROR: LLVM ERROR: The atomic float instruction requires the following SPIR-V extension: SPV_EXT_shader_atomic_float_min_max

; CHECK: Capability AtomicFloat16MinMaxEXT
; CHECK: Extension "SPV_EXT_shader_atomic_float_min_max"
; CHECK-DAG: %[[TyFP16:[0-9]+]] = OpTypeFloat 16
; CHECK-DAG: %[[TyInt32:[0-9]+]] = OpTypeInt 32 0
; CHECK-DAG: %[[Const0:[0-9]+]] = OpConstantNull %[[TyFP16]]
; CHECK-DAG: %[[ConstHalf:[0-9]+]] = OpConstant %[[TyFP16]] 20800{{$}}
; CHECK-DAG: %[[ScopeAllSvmDevices:[0-9]+]] = OpConstantNull %[[TyInt32]]
; CHECK-DAG: %[[MemSeqCst:[0-9]+]] = OpConstant %[[TyInt32]] 16{{$}}
; CHECK-DAG: %[[ScopeDevice:[0-9]+]] = OpConstant %[[TyInt32]] 1{{$}}
; CHECK-DAG: %[[TyFP16Ptr:[0-9]+]] = OpTypePointer {{[a-zA-Z]+}} %[[TyFP16]]
; CHECK-DAG: %[[DblPtr:[0-9]+]] = OpVariable %[[TyFP16Ptr]] {{[a-zA-Z]+}} %[[Const0]]
; CHECK: OpAtomicFMinEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeAllSvmDevices]] %[[MemSeqCst]] %[[ConstHalf]]
; CHECK: OpAtomicFMaxEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeAllSvmDevices]] %[[MemSeqCst]] %[[ConstHalf]]
; CHECK: OpAtomicFMinEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeDevice]] %[[MemSeqCst]] %[[ConstHalf]]
; CHECK: OpAtomicFMaxEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeDevice]] %[[MemSeqCst]] %[[ConstHalf]]

@f = common dso_local local_unnamed_addr addrspace(1) global half 0.000000e+00, align 8

define dso_local spir_func void @test1() local_unnamed_addr {
entry:
  %minval = atomicrmw fmin ptr addrspace(1) @f, half 42.0e+00 seq_cst
  %maxval = atomicrmw fmax ptr addrspace(1) @f, half 42.0e+00 seq_cst
  ret void
}

define dso_local spir_func void @test2() local_unnamed_addr {
entry:
  %minval = tail call spir_func half @_Z21__spirv_AtomicFMinEXT(ptr addrspace(1) @f, i32 1, i32 16, half 42.000000e+00)
  %maxval = tail call spir_func half @_Z21__spirv_AtomicFMaxEXT(ptr addrspace(1) @f, i32 1, i32 16, half 42.000000e+00)
  ret void
}

declare dso_local spir_func half @_Z21__spirv_AtomicFMinEXT(ptr addrspace(1), i32, i32, half)
declare dso_local spir_func half @_Z21__spirv_AtomicFMaxEXT(ptr addrspace(1), i32, i32, half)

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"wchar_size", i32 4}
