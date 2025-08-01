; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -p loop-vectorize -force-vector-width=4 -S %s | FileCheck %s

target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"

; Test case where the pointer index with is 32 bits, but the main IV is 64 bit.
; Make sure VFxUF is adjusted accordingly.
define void @wide_ptr_induction_index_width_smaller_than_iv_width(ptr noalias %src, ptr noalias %dst.0, ptr noalias %dst.1) {
; CHECK-LABEL: define void @wide_ptr_induction_index_width_smaller_than_iv_width(
; CHECK-SAME: ptr noalias [[SRC:%.*]], ptr noalias [[DST_0:%.*]], ptr noalias [[DST_1:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    br i1 false, label %[[SCALAR_PH:.*]], label %[[VECTOR_PH:.*]]
; CHECK:       [[VECTOR_PH]]:
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr i8, ptr [[SRC]], i32 800
; CHECK-NEXT:    br label %[[VECTOR_BODY:.*]]
; CHECK:       [[VECTOR_BODY]]:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, %[[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[POINTER_PHI:%.*]] = phi ptr [ [[SRC]], %[[VECTOR_PH]] ], [ [[PTR_IND:%.*]], %[[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VECTOR_GEP:%.*]] = getelementptr i8, ptr [[POINTER_PHI]], <4 x i32> <i32 0, i32 8, i32 16, i32 24>
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP2:%.*]] = add i64 [[INDEX]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP4:%.*]] = add i64 [[INDEX]], 3
; CHECK-NEXT:    [[TMP5:%.*]] = extractelement <4 x ptr> [[VECTOR_GEP]], i32 0
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i64>, ptr [[TMP5]], align 1
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i64, ptr [[DST_0]], i64 [[TMP1]]
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i64, ptr [[DST_0]], i64 [[TMP2]]
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i64, ptr [[DST_0]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i64, ptr [[DST_0]], i64 [[TMP4]]
; CHECK-NEXT:    store <4 x i64> [[WIDE_LOAD]], ptr [[TMP7]], align 8
; CHECK-NEXT:    store ptr [[TMP5]], ptr [[TMP7]], align 8
; CHECK-NEXT:    [[TMP12:%.*]] = extractelement <4 x ptr> [[VECTOR_GEP]], i32 1
; CHECK-NEXT:    store ptr [[TMP12]], ptr [[TMP8]], align 8
; CHECK-NEXT:    [[TMP13:%.*]] = extractelement <4 x ptr> [[VECTOR_GEP]], i32 2
; CHECK-NEXT:    store ptr [[TMP13]], ptr [[TMP9]], align 8
; CHECK-NEXT:    [[TMP14:%.*]] = extractelement <4 x ptr> [[VECTOR_GEP]], i32 3
; CHECK-NEXT:    store ptr [[TMP14]], ptr [[TMP10]], align 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[PTR_IND]] = getelementptr i8, ptr [[POINTER_PHI]], i32 32
; CHECK-NEXT:    [[TMP15:%.*]] = icmp eq i64 [[INDEX_NEXT]], 100
; CHECK-NEXT:    br i1 [[TMP15]], label %[[MIDDLE_BLOCK:.*]], label %[[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       [[MIDDLE_BLOCK]]:
; CHECK-NEXT:    br label %[[SCALAR_PH]]
; CHECK:       [[SCALAR_PH]]:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 100, %[[MIDDLE_BLOCK]] ], [ 0, %[[ENTRY]] ]
; CHECK-NEXT:    [[BC_RESUME_VAL1:%.*]] = phi ptr [ [[TMP0]], %[[MIDDLE_BLOCK]] ], [ [[SRC]], %[[ENTRY]] ]
; CHECK-NEXT:    br label %[[LOOP:.*]]
; CHECK:       [[LOOP]]:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], %[[SCALAR_PH]] ], [ [[IV_NEXT:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[PTR_IV:%.*]] = phi ptr [ [[BC_RESUME_VAL1]], %[[SCALAR_PH]] ], [ [[PTR_IV_NEXT:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[L:%.*]] = load i64, ptr [[PTR_IV]], align 1
; CHECK-NEXT:    [[GEP_DST_1:%.*]] = getelementptr inbounds i64, ptr [[DST_0]], i64 [[IV]]
; CHECK-NEXT:    store i64 [[L]], ptr [[GEP_DST_1]], align 8
; CHECK-NEXT:    [[GEP_DST_0:%.*]] = getelementptr inbounds ptr, ptr [[DST_1]], i64 [[IV]]
; CHECK-NEXT:    store ptr [[PTR_IV]], ptr [[GEP_DST_1]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[PTR_IV_NEXT]] = getelementptr i8, ptr [[PTR_IV]], i32 8
; CHECK-NEXT:    [[EC:%.*]] = icmp ult i64 [[IV]], 100
; CHECK-NEXT:    br i1 [[EC]], label %[[LOOP]], label %[[EXIT:.*]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       [[EXIT]]:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %ptr.iv = phi ptr [ %src, %entry ], [ %ptr.iv.next, %loop ]
  %l = load i64, ptr %ptr.iv, align 1
  %gep.dst.1 = getelementptr inbounds i64, ptr %dst.0, i64 %iv
  store i64 %l, ptr %gep.dst.1, align 8
  %gep.dst.0 = getelementptr inbounds ptr, ptr %dst.1, i64 %iv
  store ptr %ptr.iv, ptr %gep.dst.1, align 8
  %iv.next = add i64 %iv, 1
  %ptr.iv.next = getelementptr i8, ptr %ptr.iv, i32 8
  %ec = icmp ult i64 %iv, 100
  br i1 %ec, label %loop, label %exit

exit:
  ret void
}
;.
; CHECK: [[LOOP0]] = distinct !{[[LOOP0]], [[META1:![0-9]+]], [[META2:![0-9]+]]}
; CHECK: [[META1]] = !{!"llvm.loop.isvectorized", i32 1}
; CHECK: [[META2]] = !{!"llvm.loop.unroll.runtime.disable"}
; CHECK: [[LOOP3]] = distinct !{[[LOOP3]], [[META2]], [[META1]]}
;.
