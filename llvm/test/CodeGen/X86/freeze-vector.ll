; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,X64

define <2 x i64> @freeze_insert_vector_elt(<2 x i64> %a0) {
; CHECK-LABEL: freeze_insert_vector_elt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    ret{{[l|q]}}
  %idx0 = insertelement <2 x i64> %a0, i64 0, i64 0
  %freeze0 = freeze <2 x i64> %idx0
  %idx1 = insertelement <2 x i64> %freeze0, i64 0, i64 1
  %freeze1 = freeze <2 x i64> %idx1
  ret <2 x i64> %freeze1
}

define <4 x i32> @freeze_insert_subvector(<8 x i32> %a0) nounwind {
; CHECK-LABEL: freeze_insert_subvector:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    ret{{[l|q]}}
  %x = shufflevector <8 x i32> %a0, <8 x i32> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 8, i32 9, i32 10, i32 11>
  %y = freeze <8 x i32> %x
  %z = shufflevector <8 x i32> %y, <8 x i32> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  ret <4 x i32> %z
}

define <2 x i64> @freeze_sign_extend_vector_inreg(<16 x i8> %a0) nounwind {
; CHECK-LABEL: freeze_sign_extend_vector_inreg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovsxbq %xmm0, %xmm0
; CHECK-NEXT:    ret{{[l|q]}}
  %x = sext <16 x i8> %a0 to <16 x i32>
  %y = shufflevector <16 x i32> %x, <16 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %z = freeze <4 x i32> %y
  %w = sext <4 x i32> %z to <4 x i64>
  %r = shufflevector <4 x i64> %w, <4 x i64> poison, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %r
}

define <2 x i64> @freeze_zero_extend_vector_inreg(<16 x i8> %a0) nounwind {
; CHECK-LABEL: freeze_zero_extend_vector_inreg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; CHECK-NEXT:    ret{{[l|q]}}
  %x = zext <16 x i8> %a0 to <16 x i32>
  %y = shufflevector <16 x i32> %x, <16 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %z = freeze <4 x i32> %y
  %w = zext <4 x i32> %z to <4 x i64>
  %r = shufflevector <4 x i64> %w, <4 x i64> poison, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %r
}

define <4 x i32> @freeze_pshufd(<4 x i32> %a0) nounwind {
; CHECK-LABEL: freeze_pshufd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ret{{[l|q]}}
  %x = shufflevector <4 x i32> %a0, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %y = freeze <4 x i32> %x
  %z = shufflevector <4 x i32> %y, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  ret <4 x i32> %z
}

define <4 x float> @freeze_permilps(<4 x float> %a0) nounwind {
; CHECK-LABEL: freeze_permilps:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ret{{[l|q]}}
  %x = shufflevector <4 x float> %a0, <4 x float> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %y = freeze <4 x float> %x
  %z = shufflevector <4 x float> %y, <4 x float> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  ret <4 x float> %z
}

define void @freeze_bitcast_from_wider_elt(ptr %origin, ptr %dst) nounwind {
; X86-LABEL: freeze_bitcast_from_wider_elt:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    vmovsd %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_bitcast_from_wider_elt:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    retq
  %i0 = load <4 x i16>, ptr %origin
  %i1 = bitcast <4 x i16> %i0 to <8 x i8>
  %i2 = freeze <8 x i8> %i1
  %i3 = bitcast <8 x i8> %i2 to i64
  store i64 %i3, ptr %dst
  ret void
}
define void @freeze_bitcast_from_wider_elt_escape(ptr %origin, ptr %escape, ptr %dst) nounwind {
; X86-LABEL: freeze_bitcast_from_wider_elt_escape:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    vmovsd %xmm0, (%ecx)
; X86-NEXT:    vmovsd %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_bitcast_from_wider_elt_escape:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    movq %rax, (%rdx)
; X64-NEXT:    retq
  %i0 = load <4 x i16>, ptr %origin
  %i1 = bitcast <4 x i16> %i0 to <8 x i8>
  store <8 x i8> %i1, ptr %escape
  %i2 = freeze <8 x i8> %i1
  %i3 = bitcast <8 x i8> %i2 to i64
  store i64 %i3, ptr %dst
  ret void
}

define void @freeze_bitcast_to_wider_elt(ptr %origin, ptr %dst) nounwind {
; X86-LABEL: freeze_bitcast_to_wider_elt:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    vmovsd %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_bitcast_to_wider_elt:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    retq
  %i0 = load <8 x i8>, ptr %origin
  %i1 = bitcast <8 x i8> %i0 to <4 x i16>
  %i2 = freeze <4 x i16> %i1
  %i3 = bitcast <4 x i16> %i2 to i64
  store i64 %i3, ptr %dst
  ret void
}
define void @freeze_bitcast_to_wider_elt_escape(ptr %origin, ptr %escape, ptr %dst) nounwind {
; X86-LABEL: freeze_bitcast_to_wider_elt_escape:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    vmovsd %xmm0, (%ecx)
; X86-NEXT:    vmovsd %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_bitcast_to_wider_elt_escape:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    movq %rax, (%rdx)
; X64-NEXT:    retq
  %i0 = load <8 x i8>, ptr %origin
  %i1 = bitcast <8 x i8> %i0 to <4 x i16>
  store <4 x i16> %i1, ptr %escape
  %i2 = freeze <4 x i16> %i1
  %i3 = bitcast <4 x i16> %i2 to i64
  store i64 %i3, ptr %dst
  ret void
}

define void @freeze_extractelement(ptr %origin0, ptr %origin1, ptr %dst) nounwind {
; X86-LABEL: freeze_extractelement:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    vmovdqa (%edx), %xmm0
; X86-NEXT:    vpand (%ecx), %xmm0, %xmm0
; X86-NEXT:    vpextrb $6, %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_extractelement:
; X64:       # %bb.0:
; X64-NEXT:    vmovdqa (%rdi), %xmm0
; X64-NEXT:    vpand (%rsi), %xmm0, %xmm0
; X64-NEXT:    vpextrb $6, %xmm0, (%rdx)
; X64-NEXT:    retq
  %i0 = load <16 x i8>, ptr %origin0
  %i1 = load <16 x i8>, ptr %origin1
  %i2 = and <16 x i8> %i0, %i1
  %i3 = freeze <16 x i8> %i2
  %i4 = extractelement <16 x i8> %i3, i64 6
  store i8 %i4, ptr %dst
  ret void
}
define void @freeze_extractelement_escape(ptr %origin0, ptr %origin1, ptr %dst, ptr %escape) nounwind {
; X86-LABEL: freeze_extractelement_escape:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    vmovdqa (%esi), %xmm0
; X86-NEXT:    vpand (%edx), %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%ecx)
; X86-NEXT:    vpextrb $6, %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: freeze_extractelement_escape:
; X64:       # %bb.0:
; X64-NEXT:    vmovdqa (%rdi), %xmm0
; X64-NEXT:    vpand (%rsi), %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%rcx)
; X64-NEXT:    vpextrb $6, %xmm0, (%rdx)
; X64-NEXT:    retq
  %i0 = load <16 x i8>, ptr %origin0
  %i1 = load <16 x i8>, ptr %origin1
  %i2 = and <16 x i8> %i0, %i1
  %i3 = freeze <16 x i8> %i2
  store <16 x i8> %i3, ptr %escape
  %i4 = extractelement <16 x i8> %i3, i64 6
  store i8 %i4, ptr %dst
  ret void
}

; It would be a miscompilation to pull freeze out of extractelement here.
define void @freeze_extractelement_extra_use(ptr %origin0, ptr %origin1, i64 %idx0, i64 %idx1, ptr %dst, ptr %escape) nounwind {
; X86-LABEL: freeze_extractelement_extra_use:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    andl $-16, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    movl 24(%ebp), %eax
; X86-NEXT:    andl $15, %eax
; X86-NEXT:    movl 16(%ebp), %ecx
; X86-NEXT:    andl $15, %ecx
; X86-NEXT:    movl 32(%ebp), %edx
; X86-NEXT:    movl 12(%ebp), %esi
; X86-NEXT:    movl 8(%ebp), %edi
; X86-NEXT:    vmovaps (%edi), %xmm0
; X86-NEXT:    vandps (%esi), %xmm0, %xmm0
; X86-NEXT:    vmovaps %xmm0, (%esp)
; X86-NEXT:    movzbl (%esp,%ecx), %ecx
; X86-NEXT:    cmpb (%esp,%eax), %cl
; X86-NEXT:    sete (%edx)
; X86-NEXT:    leal -8(%ebp), %esp
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: freeze_extractelement_extra_use:
; X64:       # %bb.0:
; X64-NEXT:    andl $15, %ecx
; X64-NEXT:    andl $15, %edx
; X64-NEXT:    vmovaps (%rdi), %xmm0
; X64-NEXT:    vandps (%rsi), %xmm0, %xmm0
; X64-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movzbl -24(%rsp,%rdx), %eax
; X64-NEXT:    cmpb -24(%rsp,%rcx), %al
; X64-NEXT:    sete (%r8)
; X64-NEXT:    retq
  %i0 = load <16 x i8>, ptr %origin0
  %i1 = load <16 x i8>, ptr %origin1
  %i2 = and <16 x i8> %i0, %i1
  %i3 = freeze <16 x i8> %i2
  %i4 = extractelement <16 x i8> %i3, i64 %idx0
  %i5 = extractelement <16 x i8> %i3, i64 %idx1
  %i6 = icmp eq i8 %i4, %i5
  store i1 %i6, ptr %dst
  ret void
}

define void @freeze_buildvector_single_maybe_poison_operand(ptr %origin, ptr %dst) nounwind {
; X86-LABEL: freeze_buildvector_single_maybe_poison_operand:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    vbroadcastss {{.*#+}} xmm0 = [42,42,42,42]
; X86-NEXT:    vpinsrd $0, (%ecx), %xmm0, %xmm0
; X86-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_buildvector_single_maybe_poison_operand:
; X64:       # %bb.0:
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm0 = [42,42,42,42]
; X64-NEXT:    vpinsrd $0, (%rdi), %xmm0, %xmm0
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [7,7,7,7]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%rsi)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin
  %i0 = and i32 %i0.src, 15
  %i1 = insertelement <4 x i32> poison, i32 %i0, i64 0
  %i2 = insertelement <4 x i32> %i1, i32 42, i64 1
  %i3 = insertelement <4 x i32> %i2, i32 42, i64 2
  %i4 = insertelement <4 x i32> %i3, i32 42, i64 3
  %i5 = freeze <4 x i32> %i4
  %i6 = and <4 x i32> %i5, <i32 7, i32 7, i32 7, i32 7>
  store <4 x i32> %i6, ptr %dst
  ret void
}

define void @freeze_buildvector_single_repeated_maybe_poison_operand(ptr %origin, ptr %dst) nounwind {
; X86-LABEL: freeze_buildvector_single_repeated_maybe_poison_operand:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl (%ecx), %ecx
; X86-NEXT:    andl $15, %ecx
; X86-NEXT:    vbroadcastss {{.*#+}} xmm0 = [42,42,42,42]
; X86-NEXT:    vpinsrd $0, %ecx, %xmm0, %xmm0
; X86-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; X86-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_buildvector_single_repeated_maybe_poison_operand:
; X64:       # %bb.0:
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm0 = [42,42,42,42]
; X64-NEXT:    vpinsrd $0, (%rdi), %xmm0, %xmm0
; X64-NEXT:    vpbroadcastq %xmm0, %xmm0
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [7,7,7,7]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%rsi)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin
  %i0 = and i32 %i0.src, 15
  %i1 = insertelement <4 x i32> poison, i32 %i0, i64 0
  %i2 = insertelement <4 x i32> %i1, i32 42, i64 1
  %i3 = insertelement <4 x i32> %i2, i32 %i0, i64 2
  %i4 = insertelement <4 x i32> %i3, i32 42, i64 3
  %i5 = freeze <4 x i32> %i4
  %i6 = and <4 x i32> %i5, <i32 7, i32 7, i32 7, i32 7>
  store <4 x i32> %i6, ptr %dst
  ret void
}

define void @freeze_two_frozen_buildvectors(ptr %origin0, ptr %origin1, ptr %dst0, ptr %dst1) nounwind {
; X86-LABEL: freeze_two_frozen_buildvectors:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl (%esi), %esi
; X86-NEXT:    andl $15, %esi
; X86-NEXT:    movl (%edx), %edx
; X86-NEXT:    andl $15, %edx
; X86-NEXT:    vmovd %esi, %xmm0
; X86-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; X86-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; X86-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3],xmm1[4,5,6,7]
; X86-NEXT:    vbroadcastss {{.*#+}} xmm2 = [7,7,7,7]
; X86-NEXT:    vpand %xmm2, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%ecx)
; X86-NEXT:    vmovd %edx, %xmm0
; X86-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; X86-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0,1,2,3],xmm0[4,5],xmm1[6,7]
; X86-NEXT:    vpand %xmm2, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: freeze_two_frozen_buildvectors:
; X64:       # %bb.0:
; X64-NEXT:    movl (%rsi), %eax
; X64-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    vpbroadcastd %xmm0, %xmm0
; X64-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; X64-NEXT:    vpblendd {{.*#+}} xmm0 = xmm1[0],xmm0[1],xmm1[2,3]
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [7,7,7,7]
; X64-NEXT:    vpand %xmm2, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%rdx)
; X64-NEXT:    vmovd %eax, %xmm0
; X64-NEXT:    vpbroadcastd %xmm0, %xmm0
; X64-NEXT:    vpblendd {{.*#+}} xmm0 = xmm1[0,1],xmm0[2],xmm1[3]
; X64-NEXT:    vpand %xmm2, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%rcx)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin0
  %i0 = and i32 %i0.src, 15
  %i1.src = load i32, ptr %origin1
  %i1 = and i32 %i1.src, 15
  %i2 = insertelement <4 x i32> poison, i32 %i0, i64 1
  %i3 = and <4 x i32> %i2, <i32 7, i32 7, i32 7, i32 7>
  %i4 = freeze <4 x i32> %i3
  store <4 x i32> %i4, ptr %dst0
  %i5 = insertelement <4 x i32> poison, i32 %i1, i64 2
  %i6 = and <4 x i32> %i5, <i32 7, i32 7, i32 7, i32 7>
  %i7 = freeze <4 x i32> %i6
  store <4 x i32> %i7, ptr %dst1
  ret void
}

define void @freeze_two_buildvectors_only_one_frozen(ptr %origin0, ptr %origin1, ptr %dst0, ptr %dst1) nounwind {
; X86-LABEL: freeze_two_buildvectors_only_one_frozen:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl (%esi), %esi
; X86-NEXT:    andl $15, %esi
; X86-NEXT:    vmovd %esi, %xmm0
; X86-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; X86-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; X86-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3],xmm1[4,5,6,7]
; X86-NEXT:    vbroadcastss {{.*#+}} xmm1 = [7,7,7,7]
; X86-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X86-NEXT:    vbroadcastss (%edx), %xmm2
; X86-NEXT:    vmovdqa %xmm0, (%ecx)
; X86-NEXT:    vpand %xmm1, %xmm2, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: freeze_two_buildvectors_only_one_frozen:
; X64:       # %bb.0:
; X64-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    vbroadcastss %xmm0, %xmm0
; X64-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; X64-NEXT:    vblendps {{.*#+}} xmm0 = xmm1[0],xmm0[1],xmm1[2,3]
; X64-NEXT:    vbroadcastss {{.*#+}} xmm1 = [7,7,7,7]
; X64-NEXT:    vandps %xmm1, %xmm0, %xmm0
; X64-NEXT:    vbroadcastss (%rsi), %xmm2
; X64-NEXT:    vmovaps %xmm0, (%rdx)
; X64-NEXT:    vandps %xmm1, %xmm2, %xmm0
; X64-NEXT:    vmovaps %xmm0, (%rcx)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin0
  %i0 = and i32 %i0.src, 15
  %i1.src = load i32, ptr %origin1
  %i1 = and i32 %i1.src, 15
  %i2 = insertelement <4 x i32> poison, i32 %i0, i64 1
  %i3 = and <4 x i32> %i2, <i32 7, i32 7, i32 7, i32 7>
  %i4 = freeze <4 x i32> %i3
  store <4 x i32> %i4, ptr %dst0
  %i5 = insertelement <4 x i32> poison, i32 %i1, i64 2
  %i6 = and <4 x i32> %i5, <i32 7, i32 7, i32 7, i32 7>
  store <4 x i32> %i6, ptr %dst1
  ret void
}

define void @freeze_two_buildvectors_one_undef_elt(ptr %origin0, ptr %origin1, ptr %dst0, ptr %dst1) nounwind {
; X86-LABEL: freeze_two_buildvectors_one_undef_elt:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl (%esi), %esi
; X86-NEXT:    andl $15, %esi
; X86-NEXT:    vmovd %esi, %xmm0
; X86-NEXT:    vmovddup {{.*#+}} xmm1 = [7,0,7,0]
; X86-NEXT:    # xmm1 = mem[0,0]
; X86-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X86-NEXT:    vmovddup {{.*#+}} xmm2 = mem[0,0]
; X86-NEXT:    vmovdqa %xmm0, (%ecx)
; X86-NEXT:    vpand %xmm1, %xmm2, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: freeze_two_buildvectors_one_undef_elt:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    andl $15, %eax
; X64-NEXT:    vmovd %eax, %xmm0
; X64-NEXT:    vpmovsxbq {{.*#+}} xmm1 = [7,7]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vpbroadcastq (%rsi), %xmm2
; X64-NEXT:    vmovdqa %xmm0, (%rdx)
; X64-NEXT:    vpand %xmm1, %xmm2, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%rcx)
; X64-NEXT:    retq
  %i0.src = load i64, ptr %origin0
  %i0 = and i64 %i0.src, 15
  %i1.src = load i64, ptr %origin1
  %i1 = and i64 %i1.src, 15
  %i2 = insertelement <2 x i64> poison, i64 %i0, i64 0
  %i3 = and <2 x i64> %i2, <i64 7, i64 7>
  %i4 = freeze <2 x i64> %i3
  store <2 x i64> %i4, ptr %dst0
  %i5 = insertelement <2 x i64> poison, i64 %i1, i64 1
  %i6 = and <2 x i64> %i5, <i64 7, i64 7>
  store <2 x i64> %i6, ptr %dst1
  ret void
}

define void @freeze_buildvector(ptr %origin0, ptr %origin1, ptr %origin2, ptr %origin3, ptr %dst) nounwind {
; X86-LABEL: freeze_buildvector:
; X86:       # %bb.0:
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    vpinsrd $1, (%esi), %xmm0, %xmm0
; X86-NEXT:    vpinsrd $2, (%edx), %xmm0, %xmm0
; X86-NEXT:    vpinsrd $3, (%ecx), %xmm0, %xmm0
; X86-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    retl
;
; X64-LABEL: freeze_buildvector:
; X64:       # %bb.0:
; X64-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    vpinsrd $1, (%rsi), %xmm0, %xmm0
; X64-NEXT:    vpinsrd $2, (%rdx), %xmm0, %xmm0
; X64-NEXT:    vpinsrd $3, (%rcx), %xmm0, %xmm0
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [7,7,7,7]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%r8)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin0
  %i1.src = load i32, ptr %origin1
  %i2.src = load i32, ptr %origin2
  %i3.src = load i32, ptr %origin3
  %i0 = and i32 %i0.src, 15
  %i1 = and i32 %i1.src, 15
  %i2 = and i32 %i2.src, 15
  %i3 = and i32 %i3.src, 15
  %i4 = insertelement <4 x i32> poison, i32 %i0, i64 0
  %i5 = insertelement <4 x i32> %i4, i32 %i1, i64 1
  %i6 = insertelement <4 x i32> %i5, i32 %i2, i64 2
  %i7 = insertelement <4 x i32> %i6, i32 %i3, i64 3
  %i8 = freeze <4 x i32> %i7
  %i9 = and <4 x i32> %i8, <i32 7, i32 7, i32 7, i32 7>
  store <4 x i32> %i9, ptr %dst
  ret void
}

define void @freeze_buildvector_one_undef_elt(ptr %origin0, ptr %origin1, ptr %origin2, ptr %origin3, ptr %dst) nounwind {
; X86-LABEL: freeze_buildvector_one_undef_elt:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    vpinsrd $1, (%edx), %xmm0, %xmm0
; X86-NEXT:    vpinsrd $2, %eax, %xmm0, %xmm0
; X86-NEXT:    vpinsrd $3, (%ecx), %xmm0, %xmm0
; X86-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: freeze_buildvector_one_undef_elt:
; X64:       # %bb.0:
; X64-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    vpinsrd $1, (%rsi), %xmm0, %xmm0
; X64-NEXT:    vpinsrd $2, %eax, %xmm0, %xmm0
; X64-NEXT:    vpinsrd $3, (%rcx), %xmm0, %xmm0
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [7,7,7,7]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%r8)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin0
  %i1.src = load i32, ptr %origin1
  %i3.src = load i32, ptr %origin3
  %i0 = and i32 %i0.src, 15
  %i1 = and i32 %i1.src, 15
  %i3 = and i32 %i3.src, 15
  %i4 = insertelement <4 x i32> poison, i32 %i0, i64 0
  %i5 = insertelement <4 x i32> %i4, i32 %i1, i64 1
  %i7 = insertelement <4 x i32> %i5, i32 %i3, i64 3
  %i8 = freeze <4 x i32> %i7
  %i9 = and <4 x i32> %i8, <i32 7, i32 7, i32 7, i32 7>
  store <4 x i32> %i9, ptr %dst
  ret void
}

define void @freeze_buildvector_extrause(ptr %origin0, ptr %origin1, ptr %origin2, ptr %origin3, ptr %dst, ptr %escape) nounwind {
; X86-LABEL: freeze_buildvector_extrause:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebx
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    vpinsrd $1, (%edi), %xmm0, %xmm0
; X86-NEXT:    vpinsrd $2, (%esi), %xmm0, %xmm0
; X86-NEXT:    vpinsrd $3, (%edx), %xmm0, %xmm0
; X86-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%ecx)
; X86-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}, %xmm0, %xmm0
; X86-NEXT:    vmovdqa %xmm0, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    popl %ebx
; X86-NEXT:    retl
;
; X64-LABEL: freeze_buildvector_extrause:
; X64:       # %bb.0:
; X64-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    vpinsrd $1, (%rsi), %xmm0, %xmm0
; X64-NEXT:    vpinsrd $2, (%rdx), %xmm0, %xmm0
; X64-NEXT:    vpinsrd $3, (%rcx), %xmm0, %xmm0
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [15,15,15,15]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%r9)
; X64-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [7,7,7,7]
; X64-NEXT:    vpand %xmm1, %xmm0, %xmm0
; X64-NEXT:    vmovdqa %xmm0, (%r8)
; X64-NEXT:    retq
  %i0.src = load i32, ptr %origin0
  %i1.src = load i32, ptr %origin1
  %i2.src = load i32, ptr %origin2
  %i3.src = load i32, ptr %origin3
  %i0 = and i32 %i0.src, 15
  %i1 = and i32 %i1.src, 15
  %i2 = and i32 %i2.src, 15
  %i3 = and i32 %i3.src, 15
  %i4 = insertelement <4 x i32> poison, i32 %i0, i64 0
  %i5 = insertelement <4 x i32> %i4, i32 %i1, i64 1
  %i6 = insertelement <4 x i32> %i5, i32 %i2, i64 2
  %i7 = insertelement <4 x i32> %i6, i32 %i3, i64 3
  store <4 x i32> %i7, ptr %escape
  %i8 = freeze <4 x i32> %i7
  %i9 = and <4 x i32> %i8, <i32 7, i32 7, i32 7, i32 7>
  store <4 x i32> %i9, ptr %dst
  ret void
}

define void @pr59677(i32 %x, ptr %out) nounwind {
; X86-LABEL: pr59677:
; X86:       # %bb.0:
; X86-NEXT:    pushl %esi
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    vpaddd %xmm0, %xmm0, %xmm0
; X86-NEXT:    vcvtdq2ps %xmm0, %xmm0
; X86-NEXT:    vmovss %xmm0, (%esp)
; X86-NEXT:    calll sinf
; X86-NEXT:    fstps (%esi)
; X86-NEXT:    addl $4, %esp
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: pr59677:
; X64:       # %bb.0:
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq %rsi, %rbx
; X64-NEXT:    vmovd %edi, %xmm0
; X64-NEXT:    vpaddd %xmm0, %xmm0, %xmm0
; X64-NEXT:    vcvtdq2ps %xmm0, %xmm0
; X64-NEXT:    callq sinf@PLT
; X64-NEXT:    vmovss %xmm0, (%rbx)
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
  %i0 = or i32 %x, 1
  %i1 = insertelement <4 x i32> zeroinitializer, i32 %x, i64 0
  %i2 = insertelement <4 x i32> %i1, i32 %i0, i64 1
  %i3 = shl <4 x i32> %i2, <i32 1, i32 1, i32 1, i32 1>
  %i4 = sitofp <4 x i32> %i3 to <4 x float>
  %i5 = tail call <4 x float> @llvm.sin.v4f32(<4 x float> %i4)
  %i6 = extractelement <4 x float> %i5, i64 0
  store float %i6, ptr %out, align 4
  ret void
}
declare <4 x float> @llvm.sin.v4f32(<4 x float>)

; Test that we can eliminate freeze by changing the BUILD_VECTOR to a splat
; zero vector.
define void @freeze_buildvector_not_simple_type(ptr %dst) nounwind {
; X86-LABEL: freeze_buildvector_not_simple_type:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movb $0, 4(%eax)
; X86-NEXT:    movl $0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: freeze_buildvector_not_simple_type:
; X64:       # %bb.0:
; X64-NEXT:    movb $0, 4(%rdi)
; X64-NEXT:    movl $0, (%rdi)
; X64-NEXT:    retq
  %i0 = freeze <5 x i8> <i8 poison, i8 0, i8 0, i8 undef, i8 0>
  store <5 x i8> %i0, ptr %dst
  ret void
}
