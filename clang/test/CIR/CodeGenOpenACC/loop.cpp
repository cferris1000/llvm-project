// RUN: %clang_cc1 -fopenacc -Wno-openacc-self-if-potential-conflict -emit-cir -fclangir %s -o - | FileCheck %s

extern "C" void acc_loop(int *A, int *B, int *C, int N) {
  // CHECK: cir.func @acc_loop(%[[ARG_A:.*]]: !cir.ptr<!s32i> loc{{.*}}, %[[ARG_B:.*]]: !cir.ptr<!s32i> loc{{.*}}, %[[ARG_C:.*]]: !cir.ptr<!s32i> loc{{.*}}, %[[ARG_N:.*]]: !s32i loc{{.*}}) {
  // CHECK-NEXT: %[[ALLOCA_A:.*]] = cir.alloca !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>, ["A", init]
  // CHECK-NEXT: %[[ALLOCA_B:.*]] = cir.alloca !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>, ["B", init]
  // CHECK-NEXT: %[[ALLOCA_C:.*]] = cir.alloca !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>, ["C", init]
  // CHECK-NEXT: %[[ALLOCA_N:.*]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["N", init]
  // CHECK-NEXT: cir.store %[[ARG_A]], %[[ALLOCA_A]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>
  // CHECK-NEXT: cir.store %[[ARG_B]], %[[ALLOCA_B]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>
  // CHECK-NEXT: cir.store %[[ARG_C]], %[[ALLOCA_C]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>
  // CHECK-NEXT: cir.store %[[ARG_N]], %[[ALLOCA_N]] : !s32i, !cir.ptr<!s32i>


#pragma acc loop
  for (unsigned I = 0u; I < N; ++I) {
    A[I] = B[I] + C[I];
  }
  // CHECK-NEXT: acc.loop {
  // CHECK-NEXT: cir.scope {
  // CHECK: cir.for : cond {
  // CHECK: cir.condition
  // CHECK-NEXT: } body {
  // CHECK-NEXT: cir.scope {
  // CHECK: }
  // CHECK-NEXT: cir.yield
  // CHECK-NEXT: } step {
  // CHECK: cir.yield
  // CHECK-NEXT: } loc
  // CHECK-NEXT: } loc
  // CHECK-NEXT: acc.yield
  // CHECK-NEXT: } loc


#pragma acc loop seq
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {seq = [#acc.device_type<none>]} loc
#pragma acc loop device_type(nvidia, radeon) seq
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {seq = [#acc.device_type<nvidia>, #acc.device_type<radeon>]} loc
#pragma acc loop device_type(radeon) seq
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {seq = [#acc.device_type<radeon>]} loc
#pragma acc loop seq device_type(nvidia, radeon)
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {seq = [#acc.device_type<none>]} loc
#pragma acc loop seq device_type(radeon)
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {seq = [#acc.device_type<none>]} loc

#pragma acc loop independent
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {independent = [#acc.device_type<none>]} loc
#pragma acc loop device_type(nvidia, radeon) independent
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {independent = [#acc.device_type<nvidia>, #acc.device_type<radeon>]} loc
#pragma acc loop device_type(radeon) independent
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {independent = [#acc.device_type<radeon>]} loc
#pragma acc loop independent device_type(nvidia, radeon)
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {independent = [#acc.device_type<none>]} loc
#pragma acc loop independent device_type(radeon)
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {independent = [#acc.device_type<none>]} loc

#pragma acc loop auto
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {auto_ = [#acc.device_type<none>]} loc
#pragma acc loop device_type(nvidia, radeon) auto
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {auto_ = [#acc.device_type<nvidia>, #acc.device_type<radeon>]} loc
#pragma acc loop device_type(radeon) auto
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {auto_ = [#acc.device_type<radeon>]} loc
#pragma acc loop auto device_type(nvidia, radeon)
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {auto_ = [#acc.device_type<none>]} loc
#pragma acc loop auto device_type(radeon)
  for(unsigned I = 0; I < N; ++I);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {auto_ = [#acc.device_type<none>]} loc

  #pragma acc loop collapse(1) device_type(radeon)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {collapse = [1], collapseDeviceType = [#acc.device_type<none>]}

  #pragma acc loop collapse(1) device_type(radeon) collapse (2)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {collapse = [1, 2], collapseDeviceType = [#acc.device_type<none>, #acc.device_type<radeon>]}

  #pragma acc loop collapse(1) device_type(radeon, nvidia) collapse (2)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {collapse = [1, 2, 2], collapseDeviceType = [#acc.device_type<none>, #acc.device_type<radeon>, #acc.device_type<nvidia>]}
  #pragma acc loop collapse(1) device_type(radeon, nvidia) collapse(2) device_type(host) collapse(3)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK: acc.loop {
  // CHECK: acc.yield
  // CHECK-NEXT: } attributes {collapse = [1, 2, 2, 3], collapseDeviceType = [#acc.device_type<none>, #acc.device_type<radeon>, #acc.device_type<nvidia>, #acc.device_type<host>]}

  #pragma acc loop tile(1, 2, 3)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK: %[[ONE_CONST:.*]] = arith.constant 1 : i64
  // CHECK-NEXT: %[[TWO_CONST:.*]] = arith.constant 2 : i64
  // CHECK-NEXT: %[[THREE_CONST:.*]] = arith.constant 3 : i64
  // CHECK-NEXT: acc.loop tile({%[[ONE_CONST]] : i64, %[[TWO_CONST]] : i64, %[[THREE_CONST]] : i64}) {
  // CHECK: acc.yield
  // CHECK-NEXT: } loc
  #pragma acc loop tile(2) device_type(radeon)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK-NEXT: %[[TWO_CONST:.*]] = arith.constant 2 : i64
  // CHECK-NEXT: acc.loop tile({%[[TWO_CONST]] : i64}) {
  // CHECK: acc.yield
  // CHECK-NEXT: } loc
  #pragma acc loop tile(2) device_type(radeon) tile (1, *)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK-NEXT: %[[TWO_CONST:.*]] = arith.constant 2 : i64
  // CHECK-NEXT: %[[ONE_CONST:.*]] = arith.constant 1 : i64
  // CHECK-NEXT: %[[STAR_CONST:.*]] = arith.constant -1 : i64
  // CHECK-NEXT: acc.loop tile({%[[TWO_CONST]] : i64}, {%[[ONE_CONST]] : i64, %[[STAR_CONST]] : i64} [#acc.device_type<radeon>]) {
  // CHECK: acc.yield
  // CHECK-NEXT: } loc
  #pragma acc loop tile(*) device_type(radeon, nvidia) tile (1, 2)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK-NEXT: %[[STAR_CONST:.*]] = arith.constant -1 : i64
  // CHECK-NEXT: %[[ONE_CONST:.*]] = arith.constant 1 : i64
  // CHECK-NEXT: %[[TWO_CONST:.*]] = arith.constant 2 : i64
  // CHECK-NEXT: acc.loop tile({%[[STAR_CONST]] : i64}, {%[[ONE_CONST]] : i64, %[[TWO_CONST]] : i64} [#acc.device_type<radeon>], {%[[ONE_CONST]] : i64, %[[TWO_CONST]] : i64} [#acc.device_type<nvidia>]) {
  // CHECK: acc.yield
  // CHECK-NEXT: } loc
  #pragma acc loop tile(1) device_type(radeon, nvidia) tile(2, 3) device_type(host) tile(*, *, *)
  for(unsigned I = 0; I < N; ++I)
    for(unsigned J = 0; J < N; ++J)
      for(unsigned K = 0; K < N; ++K);
  // CHECK-NEXT: %[[ONE_CONST:.*]] = arith.constant 1 : i64
  // CHECK-NEXT: %[[TWO_CONST:.*]] = arith.constant 2 : i64
  // CHECK-NEXT: %[[THREE_CONST:.*]] = arith.constant 3 : i64
  // CHECK-NEXT: %[[STAR_CONST:.*]] = arith.constant -1 : i64
  // CHECK-NEXT: %[[STAR2_CONST:.*]] = arith.constant -1 : i64
  // CHECK-NEXT: %[[STAR3_CONST:.*]] = arith.constant -1 : i64
  // CHECK-NEXT: acc.loop tile({%[[ONE_CONST]] : i64}, {%[[TWO_CONST]] : i64, %[[THREE_CONST]] : i64} [#acc.device_type<radeon>], {%[[TWO_CONST]] : i64, %[[THREE_CONST]] : i64} [#acc.device_type<nvidia>], {%[[STAR_CONST]] : i64, %[[STAR2_CONST]] : i64, %[[STAR3_CONST]] : i64} [#acc.device_type<host>]) {
  // CHECK: acc.yield
  // CHECK-NEXT: } loc

}
