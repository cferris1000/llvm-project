; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -stop-after=irtranslator < %s -o - | FileCheck %s --check-prefix=ALL

%struct.f1 = type { float }
%struct.d1 = type { double }
%struct.d2 = type { double, double }
%struct.i1 = type { i32 }
%struct.i2 = type { i32, i32 }
%struct.i3 = type { i32, i32, i32 }
%struct.i4 = type { i32, i32, i32, i32 }

define float @test_return_f1(float %f.coerce) {
  ; ALL-LABEL: name: test_return_f1
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $xmm0
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $xmm0
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 4
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.f
  ; ALL-NEXT:   G_STORE [[COPY]](s32), [[FRAME_INDEX1]](p0) :: (store (s32) into %ir.coerce.dive2)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.0, align 4), (load (s8) from %ir.1, align 4)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s32) = G_LOAD [[FRAME_INDEX]](p0) :: (dereferenceable load (s32) from %ir.coerce.dive13)
  ; ALL-NEXT:   $xmm0 = COPY [[LOAD]](s32)
  ; ALL-NEXT:   RET 0, implicit $xmm0
entry:
  %retval = alloca %struct.f1, align 4
  %f = alloca %struct.f1, align 4
  %coerce.dive = getelementptr inbounds %struct.f1, ptr %f, i32 0, i32 0
  store float %f.coerce, ptr %coerce.dive, align 4
  %0 = bitcast ptr %retval to ptr
  %1 = bitcast ptr %f to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %0, ptr align 4 %1, i64 4, i1 false)
  %coerce.dive1 = getelementptr inbounds %struct.f1, ptr %retval, i32 0, i32 0
  %2 = load float, ptr %coerce.dive1, align 4
  ret float %2
}

declare void @llvm.memcpy.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1) #1

define double @test_return_d1(double %d.coerce) {
  ; ALL-LABEL: name: test_return_d1
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $xmm0
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $xmm0
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 8
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.d
  ; ALL-NEXT:   G_STORE [[COPY]](s64), [[FRAME_INDEX1]](p0) :: (store (s64) into %ir.coerce.dive2)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.0, align 8), (load (s8) from %ir.1, align 8)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s64) = G_LOAD [[FRAME_INDEX]](p0) :: (dereferenceable load (s64) from %ir.coerce.dive13)
  ; ALL-NEXT:   $xmm0 = COPY [[LOAD]](s64)
  ; ALL-NEXT:   RET 0, implicit $xmm0
entry:
  %retval = alloca %struct.d1, align 8
  %d = alloca %struct.d1, align 8
  %coerce.dive = getelementptr inbounds %struct.d1, ptr %d, i32 0, i32 0
  store double %d.coerce, ptr %coerce.dive, align 8
  %0 = bitcast ptr %retval to ptr
  %1 = bitcast ptr %d to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %1, i64 8, i1 false)
  %coerce.dive1 = getelementptr inbounds %struct.d1, ptr %retval, i32 0, i32 0
  %2 = load double, ptr %coerce.dive1, align 8
  ret double %2
}

define { double, double } @test_return_d2(double %d.coerce0, double %d.coerce1) {
  ; ALL-LABEL: name: test_return_d2
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $xmm0, $xmm1
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $xmm0
  ; ALL-NEXT:   [[COPY1:%[0-9]+]]:_(s64) = COPY $xmm1
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 16
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.d
  ; ALL-NEXT:   G_STORE [[COPY]](s64), [[FRAME_INDEX1]](p0) :: (store (s64) into %ir.1)
  ; ALL-NEXT:   [[C1:%[0-9]+]]:_(s64) = G_CONSTANT i64 8
  ; ALL-NEXT:   [[PTR_ADD:%[0-9]+]]:_(p0) = nuw nusw inbounds G_PTR_ADD [[FRAME_INDEX1]], [[C1]](s64)
  ; ALL-NEXT:   G_STORE [[COPY1]](s64), [[PTR_ADD]](p0) :: (store (s64) into %ir.2)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.3, align 8), (load (s8) from %ir.4, align 8)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s64) = G_LOAD [[FRAME_INDEX]](p0) :: (dereferenceable load (s64) from %ir.5)
  ; ALL-NEXT:   [[PTR_ADD1:%[0-9]+]]:_(p0) = nuw inbounds G_PTR_ADD [[FRAME_INDEX]], [[C1]](s64)
  ; ALL-NEXT:   [[LOAD1:%[0-9]+]]:_(s64) = G_LOAD [[PTR_ADD1]](p0) :: (dereferenceable load (s64) from %ir.5 + 8)
  ; ALL-NEXT:   $xmm0 = COPY [[LOAD]](s64)
  ; ALL-NEXT:   $xmm1 = COPY [[LOAD1]](s64)
  ; ALL-NEXT:   RET 0, implicit $xmm0, implicit $xmm1
entry:
  %retval = alloca %struct.d2, align 8
  %d = alloca %struct.d2, align 8
  %0 = bitcast ptr %d to ptr
  %1 = getelementptr inbounds { double, double }, ptr %0, i32 0, i32 0
  store double %d.coerce0, ptr %1, align 8
  %2 = getelementptr inbounds { double, double }, ptr %0, i32 0, i32 1
  store double %d.coerce1, ptr %2, align 8
  %3 = bitcast ptr %retval to ptr
  %4 = bitcast ptr %d to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %3, ptr align 8 %4, i64 16, i1 false)
  %5 = bitcast ptr %retval to ptr
  %6 = load { double, double }, ptr %5, align 8
  ret { double, double } %6
}

define i32 @test_return_i1(i32 %i.coerce) {
  ; ALL-LABEL: name: test_return_i1
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $edi
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 4
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.i
  ; ALL-NEXT:   G_STORE [[COPY]](s32), [[FRAME_INDEX1]](p0) :: (store (s32) into %ir.coerce.dive2)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.0, align 4), (load (s8) from %ir.1, align 4)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s32) = G_LOAD [[FRAME_INDEX]](p0) :: (dereferenceable load (s32) from %ir.coerce.dive13)
  ; ALL-NEXT:   $eax = COPY [[LOAD]](s32)
  ; ALL-NEXT:   RET 0, implicit $eax
entry:
  %retval = alloca %struct.i1, align 4
  %i = alloca %struct.i1, align 4
  %coerce.dive = getelementptr inbounds %struct.i1, ptr %i, i32 0, i32 0
  store i32 %i.coerce, ptr %coerce.dive, align 4
  %0 = bitcast ptr %retval to ptr
  %1 = bitcast ptr %i to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %0, ptr align 4 %1, i64 4, i1 false)
  %coerce.dive1 = getelementptr inbounds %struct.i1, ptr %retval, i32 0, i32 0
  %2 = load i32, ptr %coerce.dive1, align 4
  ret i32 %2
}

define i64 @test_return_i2(i64 %i.coerce) {
  ; ALL-LABEL: name: test_return_i2
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $rdi
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $rdi
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 8
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.i
  ; ALL-NEXT:   G_STORE [[COPY]](s64), [[FRAME_INDEX1]](p0) :: (store (s64) into %ir.0, align 4)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.1, align 4), (load (s8) from %ir.2, align 4)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s64) = G_LOAD [[FRAME_INDEX]](p0) :: (dereferenceable load (s64) from %ir.3, align 4)
  ; ALL-NEXT:   $rax = COPY [[LOAD]](s64)
  ; ALL-NEXT:   RET 0, implicit $rax
entry:
  %retval = alloca %struct.i2, align 4
  %i = alloca %struct.i2, align 4
  %0 = bitcast ptr %i to ptr
  store i64 %i.coerce, ptr %0, align 4
  %1 = bitcast ptr %retval to ptr
  %2 = bitcast ptr %i to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %2, i64 8, i1 false)
  %3 = bitcast ptr %retval to ptr
  %4 = load i64, ptr %3, align 4
  ret i64 %4
}

define { i64, i32 } @test_return_i3(i64 %i.coerce0, i32 %i.coerce1) {
  ; ALL-LABEL: name: test_return_i3
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $esi, $rdi
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $rdi
  ; ALL-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $esi
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 12
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.i
  ; ALL-NEXT:   [[FRAME_INDEX2:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.2.coerce
  ; ALL-NEXT:   [[FRAME_INDEX3:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.3.tmp
  ; ALL-NEXT:   G_STORE [[COPY]](s64), [[FRAME_INDEX2]](p0) :: (store (s64) into %ir.0, align 4)
  ; ALL-NEXT:   [[C1:%[0-9]+]]:_(s64) = G_CONSTANT i64 8
  ; ALL-NEXT:   [[PTR_ADD:%[0-9]+]]:_(p0) = nuw nusw inbounds G_PTR_ADD [[FRAME_INDEX2]], [[C1]](s64)
  ; ALL-NEXT:   G_STORE [[COPY1]](s32), [[PTR_ADD]](p0) :: (store (s32) into %ir.1)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX1]](p0), [[FRAME_INDEX2]](p0), [[C]](s64), 0 :: (store (s8) into %ir.2, align 4), (load (s8) from %ir.3, align 4)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.4, align 4), (load (s8) from %ir.5, align 4)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX3]](p0), [[FRAME_INDEX]](p0), [[C]](s64), 0 :: (store (s8) into %ir.6, align 8), (load (s8) from %ir.7, align 4)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s64) = G_LOAD [[FRAME_INDEX3]](p0) :: (dereferenceable load (s64) from %ir.tmp)
  ; ALL-NEXT:   [[PTR_ADD1:%[0-9]+]]:_(p0) = nuw inbounds G_PTR_ADD [[FRAME_INDEX3]], [[C1]](s64)
  ; ALL-NEXT:   [[LOAD1:%[0-9]+]]:_(s32) = G_LOAD [[PTR_ADD1]](p0) :: (dereferenceable load (s32) from %ir.tmp + 8, align 8)
  ; ALL-NEXT:   $rax = COPY [[LOAD]](s64)
  ; ALL-NEXT:   $edx = COPY [[LOAD1]](s32)
  ; ALL-NEXT:   RET 0, implicit $rax, implicit $edx
entry:
  %retval = alloca %struct.i3, align 4
  %i = alloca %struct.i3, align 4
  %coerce = alloca { i64, i32 }, align 4
  %tmp = alloca { i64, i32 }, align 8
  %0 = getelementptr inbounds { i64, i32 }, ptr %coerce, i32 0, i32 0
  store i64 %i.coerce0, ptr %0, align 4
  %1 = getelementptr inbounds { i64, i32 }, ptr %coerce, i32 0, i32 1
  store i32 %i.coerce1, ptr %1, align 4
  %2 = bitcast ptr %i to ptr
  %3 = bitcast ptr %coerce to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %2, ptr align 4 %3, i64 12, i1 false)
  %4 = bitcast ptr %retval to ptr
  %5 = bitcast ptr %i to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %4, ptr align 4 %5, i64 12, i1 false)
  %6 = bitcast ptr %tmp to ptr
  %7 = bitcast ptr %retval to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %6, ptr align 4 %7, i64 12, i1 false)
  %8 = load { i64, i32 }, ptr %tmp, align 8
  ret { i64, i32 } %8
}

define { i64, i64 } @test_return_i4(i64 %i.coerce0, i64 %i.coerce1) {
  ; ALL-LABEL: name: test_return_i4
  ; ALL: bb.1.entry:
  ; ALL-NEXT:   liveins: $rdi, $rsi
  ; ALL-NEXT: {{  $}}
  ; ALL-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $rdi
  ; ALL-NEXT:   [[COPY1:%[0-9]+]]:_(s64) = COPY $rsi
  ; ALL-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 16
  ; ALL-NEXT:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.retval
  ; ALL-NEXT:   [[FRAME_INDEX1:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.1.i
  ; ALL-NEXT:   G_STORE [[COPY]](s64), [[FRAME_INDEX1]](p0) :: (store (s64) into %ir.1, align 4)
  ; ALL-NEXT:   [[C1:%[0-9]+]]:_(s64) = G_CONSTANT i64 8
  ; ALL-NEXT:   [[PTR_ADD:%[0-9]+]]:_(p0) = nuw nusw inbounds G_PTR_ADD [[FRAME_INDEX1]], [[C1]](s64)
  ; ALL-NEXT:   G_STORE [[COPY1]](s64), [[PTR_ADD]](p0) :: (store (s64) into %ir.2, align 4)
  ; ALL-NEXT:   G_MEMCPY [[FRAME_INDEX]](p0), [[FRAME_INDEX1]](p0), [[C]](s64), 0 :: (store (s8) into %ir.3, align 4), (load (s8) from %ir.4, align 4)
  ; ALL-NEXT:   [[LOAD:%[0-9]+]]:_(s64) = G_LOAD [[FRAME_INDEX]](p0) :: (dereferenceable load (s64) from %ir.5, align 4)
  ; ALL-NEXT:   [[PTR_ADD1:%[0-9]+]]:_(p0) = nuw inbounds G_PTR_ADD [[FRAME_INDEX]], [[C1]](s64)
  ; ALL-NEXT:   [[LOAD1:%[0-9]+]]:_(s64) = G_LOAD [[PTR_ADD1]](p0) :: (dereferenceable load (s64) from %ir.5 + 8, align 4)
  ; ALL-NEXT:   $rax = COPY [[LOAD]](s64)
  ; ALL-NEXT:   $rdx = COPY [[LOAD1]](s64)
  ; ALL-NEXT:   RET 0, implicit $rax, implicit $rdx
entry:
  %retval = alloca %struct.i4, align 4
  %i = alloca %struct.i4, align 4
  %0 = bitcast ptr %i to ptr
  %1 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 0
  store i64 %i.coerce0, ptr %1, align 4
  %2 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %i.coerce1, ptr %2, align 4
  %3 = bitcast ptr %retval to ptr
  %4 = bitcast ptr %i to ptr
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %3, ptr align 4 %4, i64 16, i1 false)
  %5 = bitcast ptr %retval to ptr
  %6 = load { i64, i64 }, ptr %5, align 4
  ret { i64, i64 } %6
}
