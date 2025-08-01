; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=instcombine < %s | FileCheck %s

;
; Tests to show cases where computeKnownBits should be able to determine
; the known bits of a phi based on limited recursion.
;

declare i64 @llvm.ctpop.i64(i64)


define i32 @single_entry_phi(i64 %x, i1 %c) {
; CHECK-LABEL: @single_entry_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BODY:%.*]]
; CHECK:       body:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[END:%.*]], label [[BODY]]
; CHECK:       end:
; CHECK-NEXT:    [[Y:%.*]] = call range(i64 0, 65) i64 @llvm.ctpop.i64(i64 [[X:%.*]])
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc nuw nsw i64 [[Y]] to i32
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
entry:
  %y = call i64 @llvm.ctpop.i64(i64 %x)
  %trunc = trunc i64 %y to i32
  br label %body
body:
  br i1 %c, label %end, label %body
end:
  %phi = phi i32 [ %trunc, %body ]
  %res = and i32 %phi, 127
  ret i32 %res
}


define i32 @two_entry_phi_with_constant(i64 %x, i1 %c) {
; CHECK-LABEL: @two_entry_phi_with_constant(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[Y:%.*]] = call range(i64 0, 65) i64 @llvm.ctpop.i64(i64 [[X:%.*]])
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc nuw nsw i64 [[Y]] to i32
; CHECK-NEXT:    br i1 [[C:%.*]], label [[END:%.*]], label [[BODY:%.*]]
; CHECK:       body:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[TRUNC]], [[ENTRY:%.*]] ], [ 255, [[BODY]] ]
; CHECK-NEXT:    [[RES:%.*]] = and i32 [[PHI]], 255
; CHECK-NEXT:    ret i32 [[RES]]
;
entry:
  %y = call i64 @llvm.ctpop.i64(i64 %x)
  %trunc = trunc i64 %y to i32
  br i1 %c, label %end, label %body
body:
  br label %end
end:
  %phi = phi i32 [ %trunc, %entry ], [ 255, %body ]
  %res = and i32 %phi, 255
  ret i32 %res
}

define i32 @two_entry_phi_non_constant(i64 %x, i64 %x2, i1 %c) {
; CHECK-LABEL: @two_entry_phi_non_constant(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[Y:%.*]] = call range(i64 0, 65) i64 @llvm.ctpop.i64(i64 [[X:%.*]])
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc nuw nsw i64 [[Y]] to i32
; CHECK-NEXT:    br i1 [[C:%.*]], label [[END:%.*]], label [[BODY:%.*]]
; CHECK:       body:
; CHECK-NEXT:    [[Y2:%.*]] = call range(i64 0, 65) i64 @llvm.ctpop.i64(i64 [[X2:%.*]])
; CHECK-NEXT:    [[TRUNC2:%.*]] = trunc nuw nsw i64 [[Y2]] to i32
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[TRUNC]], [[ENTRY:%.*]] ], [ [[TRUNC2]], [[BODY]] ]
; CHECK-NEXT:    [[RES:%.*]] = and i32 [[PHI]], 255
; CHECK-NEXT:    ret i32 [[RES]]
;
entry:
  %y = call i64 @llvm.ctpop.i64(i64 %x)
  %trunc = trunc i64 %y to i32
  br i1 %c, label %end, label %body
body:
  %y2 = call i64 @llvm.ctpop.i64(i64 %x2)
  %trunc2 = trunc i64 %y2 to i32
  br label %end
end:
  %phi = phi i32 [ %trunc, %entry ], [ %trunc2, %body ]
  %res = and i32 %phi, 255
  ret i32 %res
}

define i32 @neg_many_branches(i64 %x) {
; CHECK-LABEL: @neg_many_branches(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[Y:%.*]] = call range(i64 0, 65) i64 @llvm.ctpop.i64(i64 [[X:%.*]])
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc nuw nsw i64 [[Y]] to i32
; CHECK-NEXT:    switch i32 [[TRUNC]], label [[END:%.*]] [
; CHECK-NEXT:      i32 1, label [[ONE:%.*]]
; CHECK-NEXT:      i32 2, label [[TWO:%.*]]
; CHECK-NEXT:      i32 3, label [[THREE:%.*]]
; CHECK-NEXT:      i32 4, label [[FOUR:%.*]]
; CHECK-NEXT:    ]
; CHECK:       one:
; CHECK-NEXT:    [[A:%.*]] = add nuw nsw i32 [[TRUNC]], 1
; CHECK-NEXT:    br label [[END]]
; CHECK:       two:
; CHECK-NEXT:    [[B:%.*]] = add nuw nsw i32 [[TRUNC]], 2
; CHECK-NEXT:    br label [[END]]
; CHECK:       three:
; CHECK-NEXT:    [[C:%.*]] = add nuw nsw i32 [[TRUNC]], 3
; CHECK-NEXT:    br label [[END]]
; CHECK:       four:
; CHECK-NEXT:    [[D:%.*]] = add nuw nsw i32 [[TRUNC]], 4
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[TRUNC]], [[ENTRY:%.*]] ], [ [[A]], [[ONE]] ], [ [[B]], [[TWO]] ], [ [[C]], [[THREE]] ], [ [[D]], [[FOUR]] ]
; CHECK-NEXT:    [[RES:%.*]] = and i32 [[PHI]], 255
; CHECK-NEXT:    ret i32 [[RES]]
;
entry:
  %y = call i64 @llvm.ctpop.i64(i64 %x)
  %trunc = trunc i64 %y to i32
  switch i32 %trunc, label %end [
  i32 1, label %one
  i32 2, label %two
  i32 3, label %three
  i32 4, label %four
  ]
one:
  %a = add i32 %trunc, 1
  br label %end
two:
  %b = add i32 %trunc, 2
  br label %end
three:
  %c = add i32 %trunc, 3
  br label %end
four:
  %d = add i32 %trunc, 4
  br label %end
end:
  %phi = phi i32 [ %trunc, %entry ], [ %a, %one ], [ %b, %two ], [ %c, %three ], [ %d, %four ]
  %res = and i32 %phi, 255
  ret i32 %res
}

define i32 @knownbits_phi_select_test1(ptr %p1, ptr %p2, i8 %x) {
; CHECK-LABEL: @knownbits_phi_select_test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVAR1:%.*]] = phi i8 [ [[LOAD2:%.*]], [[BB2:%.*]] ], [ [[X:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[INDVAR3:%.*]] = phi ptr [ [[INDVAR3_NEXT:%.*]], [[BB2]] ], [ [[P1:%.*]], [[ENTRY]] ]
; CHECK-NEXT:    [[INDVAR4:%.*]] = phi i32 [ [[INDVAR4_NEXT:%.*]], [[BB2]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    [[INDVAR5:%.*]] = phi i32 [ [[INDVAR5_NEXT:%.*]], [[BB2]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    switch i8 [[INDVAR1]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:      i8 0, label [[EXIT:%.*]]
; CHECK-NEXT:      i8 59, label [[BB1:%.*]]
; CHECK-NEXT:      i8 35, label [[BB1]]
; CHECK-NEXT:    ]
; CHECK:       default:
; CHECK-NEXT:    [[EXT:%.*]] = sext i8 [[INDVAR1]] to i64
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i16, ptr [[P2:%.*]], i64 [[EXT]]
; CHECK-NEXT:    [[LOAD1:%.*]] = load i16, ptr [[GEP1]], align 2
; CHECK-NEXT:    [[MASK:%.*]] = and i16 [[LOAD1]], 8192
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i16 [[MASK]], 0
; CHECK-NEXT:    br i1 [[CMP1]], label [[BB2]], label [[BB1]]
; CHECK:       bb1:
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ne i32 [[INDVAR4]], 0
; CHECK-NEXT:    [[CMP3:%.*]] = icmp ne i32 [[INDVAR5]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = select i1 [[CMP2]], i1 true, i1 [[CMP3]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[BB2]], label [[EXIT]]
; CHECK:       bb2:
; CHECK-NEXT:    [[CMP4:%.*]] = icmp eq i8 [[INDVAR1]], 39
; CHECK-NEXT:    [[EXT2:%.*]] = zext i1 [[CMP4]] to i32
; CHECK-NEXT:    [[INDVAR4_NEXT]] = xor i32 [[INDVAR4]], [[EXT2]]
; CHECK-NEXT:    [[CMP6:%.*]] = icmp eq i8 [[INDVAR1]], 34
; CHECK-NEXT:    [[EXT3:%.*]] = zext i1 [[CMP6]] to i32
; CHECK-NEXT:    [[INDVAR5_NEXT]] = xor i32 [[INDVAR5]], [[EXT3]]
; CHECK-NEXT:    [[INDVAR3_NEXT]] = getelementptr inbounds nuw i8, ptr [[INDVAR3]], i64 1
; CHECK-NEXT:    [[LOAD2]] = load i8, ptr [[INDVAR3_NEXT]], align 1
; CHECK-NEXT:    br label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 [[INDVAR5]]
;
entry:
  br label %loop

loop:
  %indvar1 = phi i8 [ %load2, %bb2 ], [ %x, %entry ]
  %indvar2 = phi i64 [ %indvar2.next, %bb2 ], [ 0, %entry ]
  %indvar3 = phi ptr [ %indvar3.next, %bb2 ], [ %p1, %entry ]
  %indvar4 = phi i32 [ %indvar4.next, %bb2 ], [ 0, %entry ]
  %indvar5 = phi i32 [ %indvar5.next, %bb2 ], [ 0, %entry ]
  switch i8 %indvar1, label %default [
  i8 0, label %exit
  i8 59, label %bb1
  i8 35, label %bb1
  ]

default:
  %ext = sext i8 %indvar1 to i64
  %gep1 = getelementptr inbounds i16, ptr %p2, i64 %ext
  %load1 = load i16, ptr %gep1, align 2
  %mask = and i16 %load1, 8192
  %cmp1 = icmp eq i16 %mask, 0
  br i1 %cmp1, label %bb2, label %bb1

bb1:
  %cmp2 = icmp ne i32 %indvar4, 0
  %cmp3 = icmp ne i32 %indvar5, 0
  %or.cond = select i1 %cmp2, i1 true, i1 %cmp3
  br i1 %or.cond, label %bb2, label %exit

bb2:
  %cmp4 = icmp eq i8 %indvar1, 39
  %cmp5 = icmp eq i32 %indvar4, 0
  %ext2 = zext i1 %cmp5 to i32
  %indvar4.next = select i1 %cmp4, i32 %ext2, i32 %indvar4
  %cmp6 = icmp eq i8 %indvar1, 34
  %cmp7 = icmp eq i32 %indvar5, 0
  %ext3 = zext i1 %cmp7 to i32
  %indvar5.next = select i1 %cmp6, i32 %ext3, i32 %indvar5
  %indvar3.next = getelementptr inbounds i8, ptr %indvar3, i64 1
  %indvar2.next = add i64 %indvar2, 1
  %load2 = load i8, ptr %indvar3.next, align 1
  br label %loop

exit:
  ret i32 %indvar5
}

define i8 @knownbits_phi_select_test2() {
; CHECK-LABEL: @knownbits_phi_select_test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVAR:%.*]] = phi i8 [ 0, [[ENTRY:%.*]] ], [ [[CONTAIN:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[COND0:%.*]] = call i1 @cond()
; CHECK-NEXT:    [[CONTAIN]] = select i1 [[COND0]], i8 1, i8 [[INDVAR]]
; CHECK-NEXT:    [[COND1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND1]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i8 [[CONTAIN]]
;
entry:
  br label %loop

loop:
  %indvar = phi i8 [ 0, %entry ], [ %contain, %loop ]
  %cond0 = call i1 @cond()
  %contain = select i1 %cond0, i8 1, i8 %indvar
  %cond1 = call i1 @cond()
  br i1 %cond1, label %exit, label %loop

exit:
  %bool = and i8 %contain, 1
  ret i8 %bool
}

define i8 @knownbits_umax_select_test() {
; CHECK-LABEL: @knownbits_umax_select_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[COND0:%.*]] = call i1 @cond()
; CHECK-NEXT:    [[COND1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND1]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i8 1
;
entry:
  br label %loop

loop:
  %indvar = phi i8 [ 0, %entry ], [ %contain, %loop ]
  %cond0 = call i1 @cond()
  %contain = call i8 @llvm.umax.i8(i8 1, i8 %indvar)
  %cond1 = call i1 @cond()
  br i1 %cond1, label %exit, label %loop

exit:
  %bool = and i8 %contain, 1
  ret i8 %bool
}

define i8 @knownbits_phi_phi_test() {
; CHECK-LABEL: @knownbits_phi_phi_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVAR:%.*]] = phi i8 [ 0, [[ENTRY:%.*]] ], [ [[CONTAIN:%.*]], [[LOOP_BB1:%.*]] ]
; CHECK-NEXT:    [[COND0:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND0]], label [[LOOP_BB0:%.*]], label [[LOOP_BB1]]
; CHECK:       loop.bb0:
; CHECK-NEXT:    call void @side.effect()
; CHECK-NEXT:    br label [[LOOP_BB1]]
; CHECK:       loop.bb1:
; CHECK-NEXT:    [[CONTAIN]] = phi i8 [ 1, [[LOOP_BB0]] ], [ [[INDVAR]], [[LOOP]] ]
; CHECK-NEXT:    [[COND1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND1]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i8 [[CONTAIN]]
;
entry:
  br label %loop

loop:
  %indvar = phi i8 [ 0, %entry ], [ %contain, %loop.bb1 ]
  %cond0 = call i1 @cond()
  br i1 %cond0, label %loop.bb0, label %loop.bb1
loop.bb0:
  call void @side.effect()
  br label %loop.bb1
loop.bb1:
  %contain = phi i8 [ 1, %loop.bb0 ], [ %indvar, %loop ]
  %cond1 = call i1 @cond()
  br i1 %cond1, label %exit, label %loop

exit:
  %bool = and i8 %contain, 1
  ret i8 %bool
}


define i1 @known_non_zero_phi_phi_test() {
; CHECK-LABEL: @known_non_zero_phi_phi_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVAR:%.*]] = phi i8 [ 2, [[ENTRY:%.*]] ], [ [[CONTAIN:%.*]], [[LOOP_BB1:%.*]] ]
; CHECK-NEXT:    [[COND0:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND0]], label [[LOOP_BB0:%.*]], label [[LOOP_BB1]]
; CHECK:       loop.bb0:
; CHECK-NEXT:    call void @side.effect()
; CHECK-NEXT:    br label [[LOOP_BB1]]
; CHECK:       loop.bb1:
; CHECK-NEXT:    [[CONTAIN]] = phi i8 [ 1, [[LOOP_BB0]] ], [ [[INDVAR]], [[LOOP]] ]
; CHECK-NEXT:    [[COND1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND1]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    [[BOOL:%.*]] = icmp eq i8 [[CONTAIN]], 0
; CHECK-NEXT:    ret i1 [[BOOL]]
;
entry:
  br label %loop

loop:
  %indvar = phi i8 [ 2, %entry ], [ %contain, %loop.bb1 ]
  %cond0 = call i1 @cond()
  br i1 %cond0, label %loop.bb0, label %loop.bb1
loop.bb0:
  call void @side.effect()
  br label %loop.bb1
loop.bb1:
  %contain = phi i8 [ 1, %loop.bb0 ], [ %indvar, %loop ]
  %cond1 = call i1 @cond()
  br i1 %cond1, label %exit, label %loop

exit:
  %bool = icmp eq i8 %contain, 0
  ret i1 %bool
}

define i1 @known_non_zero_phi_select_test() {
; CHECK-LABEL: @known_non_zero_phi_select_test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVAR:%.*]] = phi i8 [ 2, [[ENTRY:%.*]] ], [ [[CONTAIN:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[COND0:%.*]] = call i1 @cond()
; CHECK-NEXT:    [[CONTAIN]] = select i1 [[COND0]], i8 1, i8 [[INDVAR]]
; CHECK-NEXT:    [[COND1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[COND1]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    [[BOOL:%.*]] = icmp eq i8 [[CONTAIN]], 0
; CHECK-NEXT:    ret i1 [[BOOL]]
;
entry:
  br label %loop

loop:
  %indvar = phi i8 [ 2, %entry ], [ %contain, %loop ]
  %cond0 = call i1 @cond()
  %contain = select i1 %cond0, i8 1, i8 %indvar
  %cond1 = call i1 @cond()
  br i1 %cond1, label %exit, label %loop

exit:
  %bool = icmp eq i8 %contain, 0
  ret i1 %bool
}

declare i1 @cond()
declare void @side.effect()

