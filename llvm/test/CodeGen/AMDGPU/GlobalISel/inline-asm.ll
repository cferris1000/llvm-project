; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx908 -O0 -global-isel -o - %s | FileCheck %s

define i32 @test_sgpr_reg_class_constraint() nounwind {
; CHECK-LABEL: test_sgpr_reg_class_constraint:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_mov_b32 s4, 7
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_mov_b32 s5, 8
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_add_u32 s4, s4, s5
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    v_mov_b32_e32 v0, s4
; CHECK-NEXT:    s_setpc_b64 s[30:31]
entry:
  %asm0 = tail call i32 asm "s_mov_b32 $0, 7", "=s"() nounwind
  %asm1 = tail call i32 asm "s_mov_b32 $0, 8", "=s"() nounwind
  %asm2 = tail call i32 asm "s_add_u32 $0, $1, $2", "=s,s,s"(i32 %asm0, i32 %asm1) nounwind
  ret i32 %asm2
}

define i32 @test_sgpr_matching_constraint() nounwind {
; CHECK-LABEL: test_sgpr_matching_constraint:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_mov_b32 s5, 7
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_mov_b32 s4, 8
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_add_u32 s4, s5, s4
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    v_mov_b32_e32 v0, s4
; CHECK-NEXT:    s_setpc_b64 s[30:31]
entry:
  %asm0 = tail call i32 asm "s_mov_b32 $0, 7", "=s"() nounwind
  %asm1 = tail call i32 asm "s_mov_b32 $0, 8", "=s"() nounwind
  %asm2 = tail call i32 asm "s_add_u32 $0, $1, $2", "=s,s,0"(i32 %asm0, i32 %asm1) nounwind
  ret i32 %asm2
}

define i32 @test_sgpr_to_vgpr_move_reg_class_constraint() nounwind {
; CHECK-LABEL: test_sgpr_to_vgpr_move_reg_class_constraint:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_mov_b32 s4, 7
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    v_mov_b32 v0, s4
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    s_setpc_b64 s[30:31]
entry:
  %asm0 = tail call i32 asm "s_mov_b32 $0, 7", "=s"() nounwind
  %asm1 = tail call i32 asm "v_mov_b32 $0, $1", "=v,s"(i32 %asm0) nounwind
  ret i32 %asm1
}

define i32 @test_sgpr_to_vgpr_move_matching_constraint() nounwind {
; CHECK-LABEL: test_sgpr_to_vgpr_move_matching_constraint:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    s_mov_b32 s4, 7
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    v_mov_b32_e32 v0, s4
; CHECK-NEXT:    ;;#ASMSTART
; CHECK-NEXT:    v_mov_b32 v0, v0
; CHECK-NEXT:    ;;#ASMEND
; CHECK-NEXT:    s_setpc_b64 s[30:31]
entry:
  %asm0 = tail call i32 asm "s_mov_b32 $0, 7", "=s"() nounwind
  %asm1 = tail call i32 asm "v_mov_b32 $0, $1", "=v,0"(i32 %asm0) nounwind
  ret i32 %asm1
}

!0 = !{i32 70}
