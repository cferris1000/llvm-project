// RUN: mlir-opt %s --split-input-file -test-expand-math | FileCheck %s

// CHECK-LABEL: func @tanh
func.func @tanh(%arg: f32) -> f32 {
  %res = math.tanh %arg : f32
  return %res : f32
}
// CHECK-DAG: %[[ZERO:.+]] = arith.constant 0.000000e+00 : f32
// CHECK-DAG: %[[ONE:.+]] = arith.constant 1.000000e+00 : f32
// CHECK-DAG: %[[TWO:.+]] = arith.constant -2.000000e+00 : f32
// CHECK: %[[VAL0:.+]] = arith.cmpf olt, %arg0, %[[ZERO]] : f32
// CHECK: %[[VAL1:.+]] = arith.uitofp %[[VAL0]] : i1 to f32
// CHECK: %[[VAL2:.+]] = arith.mulf %[[VAL1]], %[[TWO]] : f32
// CHECK: %[[SIGN:.+]] = arith.addf %[[VAL2]], %[[ONE]] : f32
// CHECK: %[[POSX:.+]] = arith.mulf %[[SIGN]], %arg0 : f32
// CHECK: %[[NEGDOUBLEDX:.+]] = arith.mulf %[[POSX]], %[[TWO]] : f32
// CHECK: %[[EXP1:.+]] = math.exp %[[NEGDOUBLEDX]] : f32
// CHECK: %[[DIVIDEND1:.+]] = arith.subf %[[ONE]], %[[EXP1]] : f32
// CHECK: %[[DIVISOR1:.+]] = arith.addf %[[EXP1]], %[[ONE]] : f32
// CHECK: %[[POSRES:.+]] = arith.divf %[[DIVIDEND1]], %[[DIVISOR1]] : f32
// CHECK: %[[RESULT:.+]] = arith.mulf %[[SIGN]], %[[POSRES]] : f32
// CHECK: return %[[RESULT]]

// -----


// CHECK-LABEL: func @vector_tanh
func.func @vector_tanh(%arg: vector<4xf32>) -> vector<4xf32> {
  // CHECK-NOT: math.tanh
  %res = math.tanh %arg : vector<4xf32>
  return %res : vector<4xf32>
}

// -----

// CHECK-LABEL: func @tan
func.func @tan(%arg: f32) -> f32 {
  %res = math.tan %arg : f32
  return %res : f32
}

// CHECK-SAME: %[[ARG0:.+]]: f32
// CHECK: %[[SIN:.+]] = math.sin %[[ARG0]]
// CHECK: %[[COS:.+]] = math.cos %[[ARG0]]
// CHECK: %[[DIV:.+]] = arith.divf %[[SIN]], %[[COS]]


// -----

// CHECK-LABEL: func @vector_tan
func.func @vector_tan(%arg: vector<4xf32>) -> vector<4xf32> {
  %res = math.tan %arg : vector<4xf32>
  return %res : vector<4xf32>
}

// CHECK-NOT: math.tan

// -----

func.func @ctlz(%arg: i32) -> i32 {
  %res = math.ctlz %arg : i32
  return %res : i32
}

// CHECK-LABEL: @ctlz
// CHECK-SAME: %[[ARG0:.+]]: i32
// CHECK-DAG: %[[C0:.+]] = arith.constant 0 : i32
// CHECK-DAG: %[[C16:.+]] = arith.constant 16 : i32
// CHECK-DAG: %[[C65535:.+]] = arith.constant 65535 : i32
// CHECK-DAG: %[[C8:.+]] = arith.constant 8 : i32
// CHECK-DAG: %[[C16777215:.+]] = arith.constant 16777215 : i32
// CHECK-DAG: %[[C4:.+]] = arith.constant 4 : i32
// CHECK-DAG: %[[C268435455:.+]] = arith.constant 268435455 : i32
// CHECK-DAG: %[[C2:.+]] = arith.constant 2 : i32
// CHECK-DAG: %[[C1073741823:.+]] = arith.constant 1073741823 : i32
// CHECK-DAG: %[[C1:.+]] = arith.constant 1 : i32
// CHECK-DAG: %[[C2147483647:.+]] = arith.constant 2147483647 : i32
// CHECK-DAG: %[[C32:.+]] = arith.constant 32 : i32

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[ARG0]], %[[C65535]]
// CHECK: %[[SHL:.+]] = arith.shli %[[ARG0]], %[[C16]]
// CHECK: %[[SELX0:.+]] = arith.select %[[PRED]], %[[SHL]], %[[ARG0]]
// CHECK: %[[SELY0:.+]] = arith.select %[[PRED]], %[[C16]], %[[C0]]

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX0]], %[[C16777215]]
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY0]], %[[C8]]
// CHECK: %[[SHL:.+]] = arith.shli %[[SELX0]], %[[C8]]
// CHECK: %[[SELX1:.+]] = arith.select %[[PRED]], %[[SHL]], %[[SELX0]]
// CHECK: %[[SELY1:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY0]]

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX1]], %[[C268435455]] : i32
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY1]], %[[C4]]
// CHECK: %[[SHL:.+]] = arith.shli %[[SELX1]], %[[C4]]
// CHECK: %[[SELX2:.+]] = arith.select %[[PRED]], %[[SHL]], %[[SELX1]]
// CHECK: %[[SELY2:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY1]]


// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX2]], %[[C1073741823]] : i32
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY2]], %[[C2]]
// CHECK: %[[SHL:.+]] = arith.shli %[[SELX2]], %[[C2]]
// CHECK: %[[SELX3:.+]] = arith.select %[[PRED]], %[[SHL]], %[[SELX2]]
// CHECK: %[[SELY3:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY2]]

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX3]], %[[C2147483647]] : i32
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY3]], %[[C1]]
// CHECK: %[[SELY4:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY3]]

// CHECK: %[[PRED:.+]] = arith.cmpi eq, %[[ARG0]], %[[C0]] : i32
// CHECK: %[[SEL:.+]] = arith.select %[[PRED]], %[[C32]], %[[SELY4]] : i32
// CHECK: return %[[SEL]]

// -----

func.func @ctlz_vector(%arg: vector<4xi32>) -> vector<4xi32> {
  %res = math.ctlz %arg : vector<4xi32>
  return %res : vector<4xi32>
}

// CHECK-LABEL: @ctlz_vector
// CHECK-NOT: math.ctlz

// -----

// CHECK-LABEL:    func @fmaf_func
// CHECK-SAME:     ([[ARG0:%.+]]: f64, [[ARG1:%.+]]: f64, [[ARG2:%.+]]: f64) -> f64
func.func @fmaf_func(%a: f64, %b: f64, %c: f64) -> f64 {
  // CHECK-NEXT:     [[MULF:%.+]] = arith.mulf [[ARG0]], [[ARG1]]
  // CHECK-NEXT:     [[ADDF:%.+]] = arith.addf [[MULF]], [[ARG2]]
  // CHECK-NEXT:     return [[ADDF]]
  %ret = math.fma %a, %b, %c : f64
  return %ret : f64
}

// -----

// CHECK-LABEL:     func @ceilf_func
// CHECK-SAME:      ([[ARG0:%.+]]: f64) -> f64
func.func @ceilf_func(%a: f64) -> f64 {
  // CHECK-DAG:   [[CST:%.+]] = arith.constant 0.000
  // CHECK-DAG:   [[CST_0:%.+]] = arith.constant 1.000
  // CHECK-NEXT:   [[CVTI:%.+]] = arith.fptosi [[ARG0]]
  // CHECK-NEXT:   [[CVTF:%.+]] = arith.sitofp [[CVTI]]
  // CHECK-NEXT:   [[COPYSIGN:%.+]] = math.copysign [[CVTF]], [[ARG0]]
  // CHECK-NEXT:   [[COMP:%.+]] = arith.cmpf ogt, [[ARG0]], [[COPYSIGN]]
  // CHECK-NEXT:   [[INCR:%.+]] = arith.select [[COMP]], [[CST_0]], [[CST]]
  // CHECK-NEXT:   [[ADDF:%.+]] = arith.addf [[COPYSIGN]], [[INCR]]
  // CHECK-NEXT:   return [[ADDF]]
  %ret = math.ceil %a : f64
  return %ret : f64
}

// -----

// CHECK-LABEL:     func @exp2f_func
// CHECK-SAME:      ([[ARG0:%.+]]: f64) -> f64
func.func @exp2f_func(%a: f64) -> f64 {
  // CHECK-DAG:     [[CST:%.+]]  = arith.constant 0.69314718055994529
  // CHECK:         [[MULF:%.+]] = arith.mulf [[ARG0]], [[CST]]
  // CHECK:         [[EXP:%.+]]  = math.exp [[MULF]]
  // CHECK:         return [[EXP]]
  %ret = math.exp2 %a : f64
  return %ret : f64
}

// CHECK-LABEL:     func @exp2f_func_tensor
// CHECK-SAME:      ([[ARG0:%.+]]: tensor<1xf32>) -> tensor<1xf32>
func.func @exp2f_func_tensor(%a: tensor<1xf32>) -> tensor<1xf32> {
  // CHECK-DAG:     [[CST:%.+]]  = arith.constant dense<0.693147182>
  // CHECK:         [[MULF:%.+]] = arith.mulf [[ARG0]], [[CST]]
  // CHECK:         [[EXP:%.+]]  = math.exp [[MULF]]
  // CHECK:         return [[EXP]]
  %ret = math.exp2 %a : tensor<1xf32>
  return %ret : tensor<1xf32>
}

// -----

// CHECK-LABEL:      func @roundf_func
// CHECK-SAME:      (%[[ARG0:.*]]: f32) -> f32
func.func @roundf_func(%a: f32) -> f32 {
  // CHECK-DAG:       %[[HALF:.*]] = arith.constant 5.000000e-01
  // CHECK-DAG:       %[[C23:.*]] = arith.constant 23
  // CHECK-DAG:       %[[C127:.*]] = arith.constant 127
  // CHECK-DAG:       %[[EXP_MASK:.*]] = arith.constant 255
  // CHECK-DAG:       %[[SHIFT:.*]] = math.copysign %[[HALF]], %[[ARG0]]
  // CHECK-DAG:       %[[ARG_SHIFTED:.*]] = arith.addf %[[ARG0]], %[[SHIFT]]
  // CHECK-DAG:       %[[FIXED_CONVERT:.*]] = arith.fptosi %[[ARG_SHIFTED]]
  // CHECK-DAG:       %[[FP_FIXED_CONVERT_0:.*]] = arith.sitofp %[[FIXED_CONVERT]]
  // CHECK-DAG:       %[[FP_FIXED_CONVERT_1:.*]] = math.copysign %[[FP_FIXED_CONVERT_0]], %[[ARG_SHIFTED]]
  // CHECK-DAG:       %[[ARG_BITCAST:.*]] = arith.bitcast %[[ARG0]] : f32 to i32
  // CHECK-DAG:       %[[ARG_BITCAST_SHIFTED:.*]] = arith.shrui %[[ARG_BITCAST]], %[[C23]]
  // CHECK-DAG:       %[[ARG_EXP:.*]] = arith.andi %[[ARG_BITCAST_SHIFTED]], %[[EXP_MASK]]
  // CHECK-DAG:       %[[ARG_BIASED_EXP:.*]] = arith.subi %[[ARG_EXP]], %[[C127]]
  // CHECK-DAG:       %[[IS_SPECIAL_VAL:.*]] = arith.cmpi sge, %[[ARG_BIASED_EXP]], %[[C23]]
  // CHECK-DAG:       %[[RESULT:.*]] = arith.select %[[IS_SPECIAL_VAL]], %[[ARG0]], %[[FP_FIXED_CONVERT_1]]
  // CHECK:           return %[[RESULT]]
  %ret = math.round %a : f32
  return %ret : f32
}

// -----

// CHECK-LABEL:   func @powf_func
// CHECK-SAME:    (%[[ARG0:.+]]: f64, %[[ARG1:.+]]: f64) -> f64
func.func @powf_func(%a: f64, %b: f64) -> f64 {
  // CHECK: %[[LOGA:.+]] = math.log %[[ARG0]] : f64
  // CHECK: %[[MUL:.+]] = arith.mulf %[[ARG1]], %[[LOGA]] : f64
  // CHECK: %[[EXP:.+]] = math.exp %[[MUL]] : f64
  // CHECK: return %[[EXP]] : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_zero
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_zero(%a: f64) -> f64{
  // CHECK: %[[ONE:.+]] = arith.constant 1.000000e+00 : f64
  // CHECK: return %[[ONE]] : f64
  %b = arith.constant 0.0 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_one
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_one(%a: f64) -> f64{
  // CHECK: return %[[ARG0]] : f64
  %b = arith.constant 1.0 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_negone
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_negone(%a: f64) -> f64{
  // CHECK: %[[CSTONE:.+]] = arith.constant 1.000000e+00 : f64
  // CHECK: %[[DIV:.+]] = arith.divf %[[CSTONE]], %[[ARG0]] : f64
  // CHECK: return %[[DIV]] : f64
  %b = arith.constant -1.0 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_half
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_half(%a: f64) -> f64{
  // CHECK: %[[SQRT:.+]] = math.sqrt %[[ARG0]] : f64
  // CHECK: return %[[SQRT]] : f64
  %b = arith.constant 0.5 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_neghalf
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_neghalf(%a: f64) -> f64{
  // CHECK: %[[CSTONE:.+]] = arith.constant 1.000000e+00 : f64
  // CHECK: %[[SQRT:.+]] = math.sqrt %[[ARG0]] : f64
  // CHECK: %[[DIV:.+]] = arith.divf %[[CSTONE]], %[[SQRT]] : f64
  // CHECK: return %[[DIV]] : f64
  %b = arith.constant -0.5 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_two
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_two(%a: f64) -> f64{
  // CHECK: %[[MUL:.+]] = arith.mulf %[[ARG0]], %[[ARG0]] : f64
  // CHECK: return %[[MUL]] : f64
  %b = arith.constant 2.0 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_negtwo
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_negtwo(%a: f64) -> f64{
  // CHECK-DAG: %[[MUL:.+]] = arith.mulf %[[ARG0]], %[[ARG0]] : f64
  // CHECK-DAG: %[[CSTONE:.+]] = arith.constant 1.000000e+00 : f64
  // CHECK: %[[DIV:.+]] = arith.divf %[[CSTONE]], %[[MUL]] : f64
  // CHECK: return %[[DIV]] : f64
  %b = arith.constant -2.0 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// CHECK-LABEL:   func @powf_func_three
// CHECK-SAME:    (%[[ARG0:.+]]: f64) -> f64
func.func @powf_func_three(%a: f64) -> f64{
  // CHECK: %[[MUL:.+]] = arith.mulf %[[ARG0]], %[[ARG0]] : f64
  // CHECK: %[[MUL2:.+]] = arith.mulf %[[MUL]], %[[ARG0]] : f64
  // CHECK: return %[[MUL2]] : f64
  %b = arith.constant 3.0 : f64
  %ret = math.powf %a, %b : f64
  return %ret : f64
}

// -----

// CHECK-LABEL:   func.func @roundeven64
func.func @roundeven64(%arg: f64) -> f64 {
  %res = math.roundeven %arg : f64
  return %res : f64
}

// CHECK-SAME:                   %[[VAL_0:.*]]: f64) -> f64 {
// CHECK-DAG: %[[C_0:.*]] = arith.constant 0 : i64
// CHECK-DAG: %[[C_1:.*]] = arith.constant 1 : i64
// CHECK-DAG: %[[C_NEG_1:.*]] = arith.constant -1 : i64
// CHECK-DAG: %[[C_1_FLOAT:.*]] = arith.constant 1.000000e+00 : f64
// CHECK-DAG: %[[C_52:.*]] = arith.constant 52 : i64
// CHECK-DAG: %[[C_63:.*]] = arith.constant 63 : i64
// CHECK-DAG: %[[C_1023:.*]] = arith.constant 1023 : i64
// CHECK-DAG: %[[C_2251799813685248:.*]] = arith.constant 2251799813685248 : i64
// CHECK-DAG: %[[C_4503599627370495:.*]] = arith.constant 4503599627370495 : i64
// CHECK-DAG: %[[EXP_MASK:.*]] = arith.constant 2047 : i64
// CHECK:     %[[OPERAND_BITCAST:.*]] = arith.bitcast %[[VAL_0]] : f64 to i64
// CHECK:     %[[ROUND:.*]] = math.round %[[VAL_0]] : f64
// CHECK:     %[[ROUND_BITCAST:.*]] = arith.bitcast %[[ROUND]] : f64 to i64

// Get biased exponents of `round` and `operand`
// CHECK:     %[[SHIFTED_OPERAND_BITCAST:.*]] = arith.shrui %[[OPERAND_BITCAST]], %[[C_52]] : i64
// CHECK:     %[[OPERAND_EXP:.*]] = arith.andi %[[SHIFTED_OPERAND_BITCAST]], %[[EXP_MASK]] : i64
// CHECK:     %[[OPERAND_BIASED_EXP:.*]] = arith.subi %[[OPERAND_EXP]], %[[C_1023]] : i64
// CHECK:     %[[SHIFTED_ROUND_BITCAST:.*]] = arith.shrui %[[ROUND_BITCAST]], %[[C_52]] : i64
// CHECK:     %[[ROUND_EXP:.*]] = arith.andi %[[SHIFTED_ROUND_BITCAST]], %[[EXP_MASK]] : i64
// CHECK:     %[[ROUND_BIASED_EXP:.*]] = arith.subi %[[ROUND_EXP]], %[[C_1023]] : i64

// Determine if `ROUND_BITCAST` is an even whole number or a special value
// +-inf, +-nan.
//   Mask mantissa of `ROUND_BITCAST` with a mask shifted to the right by
//   `ROUND_BIASED_EXP - 1`
//   CHECK-DAG: %[[ROUND_BIASED_EXP_MINUS_1:.*]] = arith.subi %[[ROUND_BIASED_EXP]], %[[C_1]] : i64
//   CHECK-DAG: %[[CLAMPED_SHIFT_0:.*]] = arith.maxsi %[[ROUND_BIASED_EXP_MINUS_1]], %[[C_0]] : i64
//   CHECK-DAG: %[[CLAMPED_SHIFT_1:.*]] = arith.minsi %[[CLAMPED_SHIFT_0]], %[[C_63]] : i64
//   CHECK-DAG: %[[SHIFTED_MANTISSA_MASK_0:.*]] = arith.shrui %[[C_4503599627370495]], %[[CLAMPED_SHIFT_1]] : i64
//   CHECK-DAG: %[[ROUND_MASKED_MANTISSA:.*]] = arith.andi %[[ROUND_BITCAST]], %[[SHIFTED_MANTISSA_MASK_0]] : i64

//   `ROUND_BITCAST` is not even whole number or special value if masked
//   mantissa is != 0 or `ROUND_BIASED_EXP == 0`
//   CHECK-DAG: %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_0:.*]] = arith.cmpi ne, %[[ROUND_MASKED_MANTISSA]], %[[C_0]] : i64
//   CHECK-DAG: %[[ROUND_BIASED_EXP_EQ_0:.*]] = arith.cmpi eq, %[[ROUND_BIASED_EXP]], %[[C_0]] : i64
//   CHECK-DAG: %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_1:.*]] = arith.ori %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_0]], %[[ROUND_BIASED_EXP_EQ_0]] : i1

// Determine if operand is halfway between two integer values
// CHECK:     %[[OPERAND_BIASED_EXP_EQ_NEG_1:.*]] = arith.cmpi eq, %[[OPERAND_BIASED_EXP]], %[[C_NEG_1]] : i64
// CHECK:     %[[CLAMPED_SHIFT_2:.*]] = arith.maxsi %[[OPERAND_BIASED_EXP]], %[[C_0]] : i64
// CHECK:     %[[CLAMPED_SHIFT_3:.*]] = arith.minsi %[[CLAMPED_SHIFT_2]], %[[C_63]] : i64
// CHECK:     %[[SHIFTED_2_TO_9:.*]] = arith.shrui %[[C_2251799813685248]], %[[CLAMPED_SHIFT_3]] : i64

//   CHECK:     %[[EXPECTED_OPERAND_MASKED_MANTISSA:.*]] = arith.select %[[OPERAND_BIASED_EXP_EQ_NEG_1]], %[[C_0]], %[[SHIFTED_2_TO_9]] : i64

//   Mask mantissa of `OPERAND_BITCAST` with a mask shifted to the right by
//   `OPERAND_BIASED_EXP`
//   CHECK:     %[[CLAMPED_SHIFT_4:.*]] = arith.maxsi %[[OPERAND_BIASED_EXP]], %[[C_0]] : i64
//   CHECK:     %[[CLAMPED_SHIFT_5:.*]] = arith.minsi %[[CLAMPED_SHIFT_4]], %[[C_63]] : i64
//   CHECK:     %[[SHIFTED_MANTISSA_MASK_1:.*]] = arith.shrui %[[C_4503599627370495]], %[[CLAMPED_SHIFT_5]] : i64
//   CHECK:     %[[OPERAND_MASKED_MANTISSA:.*]] = arith.andi %[[OPERAND_BITCAST]], %[[SHIFTED_MANTISSA_MASK_1]] : i64

//   The operand is halfway between two integers if the masked mantissa is equal
//   to the expected mantissa and the biased exponent is in the range
//   [-1,  52).
//   CHECK-DAG: %[[OPERAND_BIASED_EXP_GE_NEG_1:.*]] = arith.cmpi sge, %[[OPERAND_BIASED_EXP]], %[[C_NEG_1]] : i64
//   CHECK-DAG: %[[OPERAND_BIASED_EXP_LT_10:.*]] = arith.cmpi slt, %[[OPERAND_BIASED_EXP]], %[[C_52]] : i64
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_0:.*]] = arith.cmpi eq, %[[OPERAND_MASKED_MANTISSA]], %[[EXPECTED_OPERAND_MASKED_MANTISSA]] : i64
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_1:.*]] = arith.andi %[[OPERAND_IS_HALFWAY_0]], %[[OPERAND_BIASED_EXP_LT_10]] : i1
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_2:.*]] = arith.andi %[[OPERAND_IS_HALFWAY_1]], %[[OPERAND_BIASED_EXP_GE_NEG_1]] : i1

// Adjust rounded operand with `round(operand) - sign(operand)` to correct the
// case where `round` rounded in the oppositve direction of `roundeven`.
// CHECK:     %[[SIGN:.*]] = math.copysign %[[C_1_FLOAT]], %[[VAL_0]] : f64
// CHECK:     %[[ROUND_SHIFTED:.*]] = arith.subf %[[ROUND]], %[[SIGN]] : f64
// CHECK:     %[[NEEDS_SHIFT:.*]] = arith.andi %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_1]], %[[OPERAND_IS_HALFWAY_2]] : i1
// CHECK:     %[[RESULT:.*]] = arith.select %[[NEEDS_SHIFT]], %[[ROUND_SHIFTED]], %[[ROUND]] : f64

// The `x - sign` adjustment does not preserve the sign when we are adjusting the value -1 to -0.
// CHECK:     %[[COPYSIGN:.*]] = math.copysign %[[RESULT]], %[[VAL_0]] : f64

// CHECK: return %[[COPYSIGN]] : f64

// -----

// CHECK-LABEL:   func.func @roundeven32
func.func @roundeven32(%arg: f32) -> f32 {
  %res = math.roundeven %arg : f32
  return %res : f32
}

// CHECK-SAME:                   %[[VAL_0:.*]]: f32) -> f32 {
// CHECK-DAG: %[[C_0:.*]] = arith.constant 0 : i32
// CHECK-DAG: %[[C_1:.*]] = arith.constant 1 : i32
// CHECK-DAG: %[[C_NEG_1:.*]] = arith.constant -1 : i32
// CHECK-DAG: %[[C_1_FLOAT:.*]] = arith.constant 1.000000e+00 : f32
// CHECK-DAG: %[[C_23:.*]] = arith.constant 23 : i32
// CHECK-DAG: %[[C_31:.*]] = arith.constant 31 : i32
// CHECK-DAG: %[[C_127:.*]] = arith.constant 127 : i32
// CHECK-DAG: %[[C_4194304:.*]] = arith.constant 4194304 : i32
// CHECK-DAG: %[[C_8388607:.*]] = arith.constant 8388607 : i32
// CHECK-DAG: %[[EXP_MASK:.*]] = arith.constant 255 : i32
// CHECK-DAG: %[[HALF:.*]] = arith.constant 5.000000e-01

// CHECK:     %[[OPERAND_BITCAST:.*]] = arith.bitcast %[[VAL_0]] : f32 to i32

// Calculate `math.round(operand)` using expansion pattern for `round` and
// bitcast result to i32
// CHECK:     %[[SHIFT:.*]] = math.copysign %[[HALF]], %[[VAL_0]]
// CHECK:     %[[ARG_SHIFTED:.*]] = arith.addf %[[VAL_0]], %[[SHIFT]]
// CHECK:     %[[FIXED_CONVERT:.*]] = arith.fptosi %[[ARG_SHIFTED]]
// CHECK:     %[[FP_FIXED_CONVERT_0:.*]] = arith.sitofp %[[FIXED_CONVERT]]
// CHECK:     %[[FP_FIXED_CONVERT_1:.*]] = math.copysign %[[FP_FIXED_CONVERT_0]], %[[ARG_SHIFTED]]
// CHECK:     %[[ARG_BITCAST:.*]] = arith.bitcast %[[VAL_0]] : f32 to i32
// CHECK:     %[[ARG_BITCAST_SHIFTED:.*]] = arith.shrui %[[ARG_BITCAST]], %[[C_23]]
// CHECK:     %[[ARG_EXP:.*]] = arith.andi %[[ARG_BITCAST_SHIFTED]], %[[EXP_MASK]]
// CHECK:     %[[ARG_BIASED_EXP:.*]] = arith.subi %[[ARG_EXP]], %[[C_127]]
// CHECK:     %[[IS_SPECIAL_VAL:.*]] = arith.cmpi sge, %[[ARG_BIASED_EXP]], %[[C_23]]
// CHECK:     %[[ROUND:.*]] = arith.select %[[IS_SPECIAL_VAL]], %[[VAL_0]], %[[FP_FIXED_CONVERT_1]]
// CHECK:     %[[ROUND_BITCAST:.*]] = arith.bitcast %[[ROUND]] : f32 to i32

// Get biased exponents of `round` and `operand`
// CHECK:     %[[SHIFTED_OPERAND_BITCAST:.*]] = arith.shrui %[[OPERAND_BITCAST]], %[[C_23]] : i32
// CHECK:     %[[OPERAND_EXP:.*]] = arith.andi %[[SHIFTED_OPERAND_BITCAST]], %[[EXP_MASK]] : i32
// CHECK:     %[[OPERAND_BIASED_EXP:.*]] = arith.subi %[[OPERAND_EXP]], %[[C_127]] : i32
// CHECK:     %[[SHIFTED_ROUND_BITCAST:.*]] = arith.shrui %[[ROUND_BITCAST]], %[[C_23]] : i32
// CHECK:     %[[ROUND_EXP:.*]] = arith.andi %[[SHIFTED_ROUND_BITCAST]], %[[EXP_MASK]] : i32
// CHECK:     %[[ROUND_BIASED_EXP:.*]] = arith.subi %[[ROUND_EXP]], %[[C_127]] : i32

// Determine if `ROUND_BITCAST` is an even whole number or a special value
// +-inf, +-nan.
//   Mask mantissa of `ROUND_BITCAST` with a mask shifted to the right by
//   `ROUND_BIASED_EXP - 1`
//   CHECK-DAG: %[[ROUND_BIASED_EXP_MINUS_1:.*]] = arith.subi %[[ROUND_BIASED_EXP]], %[[C_1]] : i32
//   CHECK-DAG: %[[CLAMPED_SHIFT_0:.*]] = arith.maxsi %[[ROUND_BIASED_EXP_MINUS_1]], %[[C_0]] : i32
//   CHECK-DAG: %[[CLAMPED_SHIFT_1:.*]] = arith.minsi %[[CLAMPED_SHIFT_0]], %[[C_31]] : i32
//   CHECK-DAG: %[[SHIFTED_MANTISSA_MASK_0:.*]] = arith.shrui %[[C_8388607]], %[[CLAMPED_SHIFT_1]] : i32
//   CHECK-DAG: %[[ROUND_MASKED_MANTISSA:.*]] = arith.andi %[[ROUND_BITCAST]], %[[SHIFTED_MANTISSA_MASK_0]] : i32

//   `ROUND_BITCAST` is not even whole number or special value if masked
//   mantissa is != 0 or `ROUND_BIASED_EXP == 0`
//   CHECK-DAG: %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_0:.*]] = arith.cmpi ne, %[[ROUND_MASKED_MANTISSA]], %[[C_0]] : i32
//   CHECK-DAG: %[[ROUND_BIASED_EXP_EQ_0:.*]] = arith.cmpi eq, %[[ROUND_BIASED_EXP]], %[[C_0]] : i32
//   CHECK-DAG: %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_1:.*]] = arith.ori %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_0]], %[[ROUND_BIASED_EXP_EQ_0]] : i1

// Determine if operand is halfway between two integer values
// CHECK:     %[[OPERAND_BIASED_EXP_EQ_NEG_1:.*]] = arith.cmpi eq, %[[OPERAND_BIASED_EXP]], %[[C_NEG_1]] : i32
// CHECK:     %[[CLAMPED_SHIFT_2:.*]] = arith.maxsi %[[OPERAND_BIASED_EXP]], %[[C_0]] : i32
// CHECK:     %[[CLAMPED_SHIFT_3:.*]] = arith.minsi %[[CLAMPED_SHIFT_2]], %[[C_31]] : i32
// CHECK:     %[[SHIFTED_2_TO_22:.*]] = arith.shrui %[[C_4194304]], %[[CLAMPED_SHIFT_3]] : i32

//   A value with `0 <= BIASED_EXP < 23` is halfway between two consecutive
//   integers if the bit at index `BIASED_EXP` starting from the left in the
//   mantissa is 1 and all the bits to the right are zero. For the case where
//   `BIASED_EXP == -1, the expected mantissa is all zeros.
//   CHECK:     %[[EXPECTED_OPERAND_MASKED_MANTISSA:.*]] = arith.select %[[OPERAND_BIASED_EXP_EQ_NEG_1]], %[[C_0]], %[[SHIFTED_2_TO_22]] : i32

//   Mask mantissa of `OPERAND_BITCAST` with a mask shifted to the right by
//   `OPERAND_BIASED_EXP`
//   CHECK:     %[[CLAMPED_SHIFT_4:.*]] = arith.maxsi %[[OPERAND_BIASED_EXP]], %[[C_0]] : i32
//   CHECK:     %[[CLAMPED_SHIFT_5:.*]] = arith.minsi %[[CLAMPED_SHIFT_4]], %[[C_31]] : i32
//   CHECK:     %[[SHIFTED_MANTISSA_MASK_1:.*]] = arith.shrui %[[C_8388607]], %[[CLAMPED_SHIFT_5]] : i32
//   CHECK:     %[[OPERAND_MASKED_MANTISSA:.*]] = arith.andi %[[OPERAND_BITCAST]], %[[SHIFTED_MANTISSA_MASK_1]] : i32

//   The operand is halfway between two integers if the masked mantissa is equal
//   to the expected mantissa and the biased exponent is in the range
//   [-1,  23).
//   CHECK-DAG: %[[OPERAND_BIASED_EXP_GE_NEG_1:.*]] = arith.cmpi sge, %[[OPERAND_BIASED_EXP]], %[[C_NEG_1]] : i32
//   CHECK-DAG: %[[OPERAND_BIASED_EXP_LT_23:.*]] = arith.cmpi slt, %[[OPERAND_BIASED_EXP]], %[[C_23]] : i32
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_0:.*]] = arith.cmpi eq, %[[OPERAND_MASKED_MANTISSA]], %[[EXPECTED_OPERAND_MASKED_MANTISSA]] : i32
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_1:.*]] = arith.andi %[[OPERAND_IS_HALFWAY_0]], %[[OPERAND_BIASED_EXP_LT_23]] : i1
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_2:.*]] = arith.andi %[[OPERAND_IS_HALFWAY_1]], %[[OPERAND_BIASED_EXP_GE_NEG_1]] : i1

// Adjust rounded operand with `round(operand) - sign(operand)` to correct the
// case where `round` rounded in the oppositve direction of `roundeven`.
// CHECK:     %[[SIGN:.*]] = math.copysign %[[C_1_FLOAT]], %[[VAL_0]] : f32
// CHECK:     %[[ROUND_SHIFTED:.*]] = arith.subf %[[ROUND]], %[[SIGN]] : f32
// CHECK:     %[[NEEDS_SHIFT:.*]] = arith.andi %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_1]], %[[OPERAND_IS_HALFWAY_2]] : i1
// CHECK:     %[[RESULT:.*]] = arith.select %[[NEEDS_SHIFT]], %[[ROUND_SHIFTED]], %[[ROUND]] : f32

// The `x - sign` adjustment does not preserve the sign when we are adjusting the value -1 to -0.
// CHECK:     %[[COPYSIGN:.*]] = math.copysign %[[RESULT]], %[[VAL_0]] : f32

// CHECK: return %[[COPYSIGN]] : f32

// -----

// CHECK-LABEL:   func.func @roundeven16
func.func @roundeven16(%arg: f16) -> f16 {
  %res = math.roundeven %arg : f16
  return %res : f16
}

// CHECK-SAME:                   %[[VAL_0:.*]]: f16) -> f16 {
// CHECK-DAG: %[[C_0:.*]] = arith.constant 0 : i16
// CHECK-DAG: %[[C_1:.*]] = arith.constant 1 : i16
// CHECK-DAG: %[[C_NEG_1:.*]] = arith.constant -1 : i16
// CHECK-DAG: %[[C_1_FLOAT:.*]] = arith.constant 1.000000e+00 : f16
// CHECK-DAG: %[[C_10:.*]] = arith.constant 10 : i16
// CHECK-DAG: %[[C_15:.*]] = arith.constant 15 : i16
// CHECK-DAG: %[[C_512:.*]] = arith.constant 512 : i16
// CHECK-DAG: %[[C_1023:.*]] = arith.constant 1023 : i16
// CHECK-DAG: %[[EXP_MASK:.*]] = arith.constant 31 : i16

// CHECK:     %[[OPERAND_BITCAST:.*]] = arith.bitcast %[[VAL_0]] : f16 to i16
// CHECK:     %[[ROUND:.*]] = math.round %[[VAL_0]] : f16
// CHECK:     %[[ROUND_BITCAST:.*]] = arith.bitcast %[[ROUND]] : f16 to i16

// Get biased exponents of `round` and `operand`
// CHECK:     %[[SHIFTED_OPERAND_BITCAST:.*]] = arith.shrui %[[OPERAND_BITCAST]], %[[C_10]] : i16
// CHECK:     %[[OPERAND_EXP:.*]] = arith.andi %[[SHIFTED_OPERAND_BITCAST]], %[[EXP_MASK]] : i16
// CHECK:     %[[OPERAND_BIASED_EXP:.*]] = arith.subi %[[OPERAND_EXP]], %[[C_15]] : i16
// CHECK:     %[[SHIFTED_ROUND_BITCAST:.*]] = arith.shrui %[[ROUND_BITCAST]], %[[C_10]] : i16
// CHECK:     %[[ROUND_EXP:.*]] = arith.andi %[[SHIFTED_ROUND_BITCAST]], %[[EXP_MASK]] : i16
// CHECK:     %[[ROUND_BIASED_EXP:.*]] = arith.subi %[[ROUND_EXP]], %[[C_15]] : i16

// Determine if `ROUND_BITCAST` is an even whole number or a special value
// +-inf, +-nan.
//   Mask mantissa of `ROUND_BITCAST` with a mask shifted to the right by
//   `ROUND_BIASED_EXP - 1`
//   CHECK-DAG: %[[ROUND_BIASED_EXP_MINUS_1:.*]] = arith.subi %[[ROUND_BIASED_EXP]], %[[C_1]] : i16
//   CHECK-DAG: %[[CLAMPED_SHIFT_0:.*]] = arith.maxsi %[[ROUND_BIASED_EXP_MINUS_1]], %[[C_0]] : i16
//   CHECK-DAG: %[[CLAMPED_SHIFT_1:.*]] = arith.minsi %[[CLAMPED_SHIFT_0]], %[[C_15]] : i16
//   CHECK-DAG: %[[SHIFTED_MANTISSA_MASK_0:.*]] = arith.shrui %[[C_1023]], %[[CLAMPED_SHIFT_1]] : i16
//   CHECK-DAG: %[[ROUND_MASKED_MANTISSA:.*]] = arith.andi %[[ROUND_BITCAST]], %[[SHIFTED_MANTISSA_MASK_0]] : i16

//   `ROUND_BITCAST` is not even whole number or special value if masked
//   mantissa is != 0 or `ROUND_BIASED_EXP == 0`
//   CHECK-DAG: %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_0:.*]] = arith.cmpi ne, %[[ROUND_MASKED_MANTISSA]], %[[C_0]] : i16
//   CHECK-DAG: %[[ROUND_BIASED_EXP_EQ_0:.*]] = arith.cmpi eq, %[[ROUND_BIASED_EXP]], %[[C_0]] : i16
//   CHECK-DAG: %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_1:.*]] = arith.ori %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_0]], %[[ROUND_BIASED_EXP_EQ_0]] : i1

// Determine if operand is halfway between two integer values
// CHECK:     %[[OPERAND_BIASED_EXP_EQ_NEG_1:.*]] = arith.cmpi eq, %[[OPERAND_BIASED_EXP]], %[[C_NEG_1]] : i16
// CHECK:     %[[CLAMPED_SHIFT_2:.*]] = arith.maxsi %[[OPERAND_BIASED_EXP]], %[[C_0]] : i16
// CHECK:     %[[CLAMPED_SHIFT_3:.*]] = arith.minsi %[[CLAMPED_SHIFT_2]], %[[C_15]] : i16
// CHECK:     %[[SHIFTED_2_TO_9:.*]] = arith.shrui %[[C_512]], %[[CLAMPED_SHIFT_3]] : i16

//   A value with `0 <= BIASED_EXP < 10` is halfway between two consecutive
//   integers if the bit at index `BIASED_EXP` starting from the left in the
//   mantissa is 1 and all the bits to the right are zero. For the case where
//   `BIASED_EXP == -1, the expected mantissa is all zeros.
//   CHECK:     %[[EXPECTED_OPERAND_MASKED_MANTISSA:.*]] = arith.select %[[OPERAND_BIASED_EXP_EQ_NEG_1]], %[[C_0]], %[[SHIFTED_2_TO_9]] : i16

//   Mask mantissa of `OPERAND_BITCAST` with a mask shifted to the right by
//   `OPERAND_BIASED_EXP`
//   CHECK:     %[[CLAMPED_SHIFT_4:.*]] = arith.maxsi %[[OPERAND_BIASED_EXP]], %[[C_0]] : i16
//   CHECK:     %[[CLAMPED_SHIFT_5:.*]] = arith.minsi %[[CLAMPED_SHIFT_4]], %[[C_15]] : i16
//   CHECK:     %[[SHIFTED_MANTISSA_MASK_1:.*]] = arith.shrui %[[C_1023]], %[[CLAMPED_SHIFT_5]] : i16
//   CHECK:     %[[OPERAND_MASKED_MANTISSA:.*]] = arith.andi %[[OPERAND_BITCAST]], %[[SHIFTED_MANTISSA_MASK_1]] : i16

//   The operand is halfway between two integers if the masked mantissa is equal
//   to the expected mantissa and the biased exponent is in the range
//   [-1,  23).
//   CHECK-DAG: %[[OPERAND_BIASED_EXP_GE_NEG_1:.*]] = arith.cmpi sge, %[[OPERAND_BIASED_EXP]], %[[C_NEG_1]] : i16
//   CHECK-DAG: %[[OPERAND_BIASED_EXP_LT_10:.*]] = arith.cmpi slt, %[[OPERAND_BIASED_EXP]], %[[C_10]] : i16
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_0:.*]] = arith.cmpi eq, %[[OPERAND_MASKED_MANTISSA]], %[[EXPECTED_OPERAND_MASKED_MANTISSA]] : i16
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_1:.*]] = arith.andi %[[OPERAND_IS_HALFWAY_0]], %[[OPERAND_BIASED_EXP_LT_10]] : i1
//   CHECK-DAG: %[[OPERAND_IS_HALFWAY_2:.*]] = arith.andi %[[OPERAND_IS_HALFWAY_1]], %[[OPERAND_BIASED_EXP_GE_NEG_1]] : i1

// Adjust rounded operand with `round(operand) - sign(operand)` to correct the
// case where `round` rounded in the oppositve direction of `roundeven`.
// CHECK:     %[[SIGN:.*]] = math.copysign %[[C_1_FLOAT]], %[[VAL_0]] : f16
// CHECK:     %[[ROUND_SHIFTED:.*]] = arith.subf %[[ROUND]], %[[SIGN]] : f16
// CHECK:     %[[NEEDS_SHIFT:.*]] = arith.andi %[[ROUND_IS_NOT_EVEN_OR_SPECIAL_1]], %[[OPERAND_IS_HALFWAY_2]] : i1
// CHECK:     %[[RESULT:.*]] = arith.select %[[NEEDS_SHIFT]], %[[ROUND_SHIFTED]], %[[ROUND]] : f16

// The `x - sign` adjustment does not preserve the sign when we are adjusting the value -1 to -0.
// CHECK:     %[[COPYSIGN:.*]] = math.copysign %[[RESULT]], %[[VAL_0]] : f16

// CHECK: return %[[COPYSIGN]] : f16

// -----

// CHECK-LABEL:   func.func @math_fpowi_neg_odd_power
func.func @math_fpowi_neg_odd_power(%0 : tensor<8xf32>) -> tensor<8xf32> {
  %1 = arith.constant dense<-3> : tensor<8xi64>
  %2 = math.fpowi %0, %1 : tensor<8xf32>, tensor<8xi64>
  return %2 : tensor<8xf32>
}
//  CHECK-SAME: (%[[ARG0:.*]]: tensor<8xf32>) -> tensor<8xf32> {
//  CHECK-DAG:    %[[CST1:.*]] = arith.constant dense<1.000000e+00> : tensor<8xf32>
//  CHECK-DAG:    %[[CST0:.*]] = arith.constant dense<0.000000e+00> : tensor<8xf32>
//  CHECK-DAG:    %[[CSTNEG0:.*]] = arith.constant dense<-0.000000e+00> : tensor<8xf32>
//  CHECK-DAG:    %[[CSTINF:.*]] = arith.constant dense<0x7F800000> : tensor<8xf32>
//  CHECK-DAG:    %[[CSTNEGINF:.*]] = arith.constant dense<0xFF800000> : tensor<8xf32>
//  CHECK:        %[[SQ:.*]] = arith.mulf %[[ARG0]], %[[ARG0]] : tensor<8xf32>
//  CHECK:        %[[CUBE:.*]] = arith.mulf %[[SQ]], %[[ARG0]] : tensor<8xf32>
//  CHECK:        %[[CMP0:.*]] = arith.cmpf oeq, %[[CUBE]], %[[CST0]] : tensor<8xf32>
//  CHECK:        %[[CMPNEG0:.*]] = arith.cmpf oeq, %[[CUBE]], %[[CSTNEG0]] : tensor<8xf32>
//  CHECK:        %[[INV:.*]] = arith.divf %[[CST1]], %[[CUBE]] : tensor<8xf32>
//  CHECK:        %[[UB1:.*]] = arith.select %[[CMP0]], %[[CSTINF]], %[[INV]] : tensor<8xi1>, tensor<8xf32>
//  CHECK:        %[[UB2:.*]] = arith.select %[[CMPNEG0]], %[[CSTNEGINF]], %[[UB1]] : tensor<8xi1>, tensor<8xf32>
//  CHECK:      return %[[UB2]] : tensor<8xf32>

// -----

// CHECK-LABEL:   func.func @math_fpowi_neg_even_power
func.func @math_fpowi_neg_even_power(%0 : tensor<8xf32>) -> tensor<8xf32> {
  %1 = arith.constant dense<-4> : tensor<8xi64>
  %2 = math.fpowi %0, %1 : tensor<8xf32>, tensor<8xi64>
  return %2 : tensor<8xf32>
}
//  CHECK-SAME: (%[[ARG0:.*]]: tensor<8xf32>) -> tensor<8xf32> {
//  CHECK-DAG:    %[[CST1:.*]] = arith.constant dense<1.000000e+00> : tensor<8xf32>
//  CHECK-DAG:    %[[CST0:.*]] = arith.constant dense<0.000000e+00> : tensor<8xf32>
//  CHECK-DAG:    %[[CSTNEG0:.*]] = arith.constant dense<-0.000000e+00> : tensor<8xf32>
//  CHECK-DAG:    %[[CSTINF:.*]] = arith.constant dense<0x7F800000> : tensor<8xf32>
//  CHECK-DAG:    %[[CSTNEGINF:.*]] = arith.constant dense<0xFF800000> : tensor<8xf32>
//  CHECK:        %[[SQ:.*]] = arith.mulf %[[ARG0]], %[[ARG0]] : tensor<8xf32>
//  CHECK:        %[[PW4:.*]] = arith.mulf %[[SQ]], %[[SQ]] : tensor<8xf32>
//  CHECK:        %[[CMP0:.*]] = arith.cmpf oeq, %[[PW4]], %[[CST0]] : tensor<8xf32>
//  CHECK:        %[[CMPNEG0:.*]] = arith.cmpf oeq, %[[PW4]], %[[CSTNEG0]] : tensor<8xf32>
//  CHECK:        %[[INV:.*]] = arith.divf %[[CST1]], %[[PW4]] : tensor<8xf32>
//  CHECK:        %[[UB1:.*]] = arith.select %[[CMP0]], %[[CSTINF]], %[[INV]] : tensor<8xi1>, tensor<8xf32>
//  CHECK:        %[[UB2:.*]] = arith.select %[[CMPNEG0]], %[[CSTNEGINF]], %[[UB1]] : tensor<8xi1>, tensor<8xf32>
//  CHECK:      return %[[UB2]] : tensor<8xf32>

// -----

// CHECK-LABEL:   func.func @math_fpowi_pos_odd_power
func.func @math_fpowi_pos_odd_power(%0 : tensor<8xf32>) -> tensor<8xf32> {
  %1 = arith.constant dense<5> : tensor<8xi64>
  %2 = math.fpowi %0, %1 : tensor<8xf32>, tensor<8xi64>
  return %2 : tensor<8xf32>
}
//  CHECK-SAME: (%[[ARG0:.*]]: tensor<8xf32>) -> tensor<8xf32> {
//  CHECK:        %[[SQ:.*]] = arith.mulf %[[ARG0]], %[[ARG0]] : tensor<8xf32>
//  CHECK:        %[[PW4:.*]] = arith.mulf %[[SQ]], %[[SQ]] : tensor<8xf32>
//  CHECK:        %[[PW5:.*]] = arith.mulf %[[PW4]], %[[ARG0]] : tensor<8xf32>
//  CHECK:      return %[[PW5]] : tensor<8xf32>

// -----

// CHECK-LABEL:   func.func @math_fpowi_pos_even_power
func.func @math_fpowi_pos_even_power(%0 : tensor<8xf32>) -> tensor<8xf32> {
  %1 = arith.constant dense<4> : tensor<8xi64>
  %2 = math.fpowi %0, %1 : tensor<8xf32>, tensor<8xi64>
  return %2 : tensor<8xf32>
}
//  CHECK-SAME: (%[[ARG0:.*]]: tensor<8xf32>) -> tensor<8xf32> {
//  CHECK:        %[[SQ:.*]] = arith.mulf %[[ARG0]], %[[ARG0]] : tensor<8xf32>
//  CHECK:        %[[PW4:.*]] = arith.mulf %[[SQ]], %[[SQ]] : tensor<8xf32>
//  CHECK:      return %[[PW4]] : tensor<8xf32>

// -----

// CHECK-LABEL:   func.func @math_fpowi_even_scalar
func.func @math_fpowi_even_scalar(%0 : f32) -> f32 {
  %pow = arith.constant 2 : i64
  %2 = math.fpowi %0, %pow : f32, i64
  return %2 : f32
}
//  CHECK-SAME: (%[[ARG0:.*]]: f32) -> f32 {
//  CHECK:         %[[SQ:.*]] = arith.mulf %[[ARG0]], %[[ARG0]] : f32
//  CHECK:         return %[[SQ]] : f32

// -----

// CHECK-LABEL:   func.func @math_fpowi_scalar_zero
func.func @math_fpowi_scalar_zero(%0 : f32) -> f32 {
  %pow = arith.constant 0 : i64
  %2 = math.fpowi %0, %pow : f32, i64
  return %2 : f32
}
//  CHECK-SAME: (%[[ARG0:.*]]: f32) -> f32 {
//  CHECK:         %[[RET:.*]] = arith.constant 1.000000e+00 : f32
//  CHECK:         return %[[RET]] : f32

// -----

// CHECK-LABEL:   func.func @math_fpowi_to_powf_tensor
func.func @math_fpowi_to_powf_tensor(%0 : tensor<8xf32>, %1: tensor<8xi32>) -> tensor<8xf32> {
  %2 = math.fpowi %0, %1 : tensor<8xf32>, tensor<8xi32>
  return %2 : tensor<8xf32>
}
// CHECK-SAME: (%[[ARG0:.*]]: tensor<8xf32>, %[[ARG1:.*]]: tensor<8xi32>) -> tensor<8xf32> {
// CHECK: %[[TOFP:.*]] = arith.sitofp %[[ARG1]] : tensor<8xi32> to tensor<8xf32>
// CHECK: %[[LOGA:.*]] = math.log %[[ARG0]] : tensor<8xf32>
// CHECK: %[[MUL:.*]] = arith.mulf %[[TOFP]], %[[LOGA]] : tensor<8xf32>
// CHECK: %[[EXP:.*]] = math.exp %[[MUL]] : tensor<8xf32>
// CHECK: return %[[EXP]]
// -----

// CHECK-LABEL:   func.func @math_fpowi_to_powf_scalar
func.func @math_fpowi_to_powf_scalar(%0 : f32, %1: i64) -> f32 {
  %2 = math.fpowi %0, %1 : f32, i64
  return %2 : f32
}
// CHECK-SAME: (%[[ARG0:.*]]: f32, %[[ARG1:.*]]: i64) -> f32 {
// CHECK:        %[[TOFP:.*]] = arith.sitofp %[[ARG1]] : i64 to f32
// CHECK:        %[[LOGA:.*]] = math.log %[[ARG0]] : f32
// CHECK:        %[[MUL:.*]] = arith.mulf %[[TOFP]], %[[LOGA]] : f32
// CHECK:        %[[EXP:.*]] = math.exp %[[MUL]] : f32
// CHECK:       return %[[EXP]] : f32

// -----

// CHECK-LABEL:   func.func @rsqrt
// CHECK-SAME:     (%[[ARG:.*]]: f16)
// CHECK-SAME:    -> f16
// CHECK-DAG:     %[[CST:.*]] = arith.constant 1.000000e+00 : f16
// CHECK-DAG:     %[[SQRT:.*]] = math.sqrt %[[ARG]] : f16
// CHECK-DAG:     %[[DIV:.*]] = arith.divf %[[CST]], %[[SQRT]] : f16
// CHECK:         return %[[DIV]] : f16
func.func @rsqrt16(%float: f16) -> (f16)  {
  %float_result = math.rsqrt %float : f16
  return %float_result : f16
}

// -----

// CHECK-LABEL:   func.func @rsqrt
// CHECK-SAME:     (%[[ARG:.*]]: f32)
// CHECK-SAME:    -> f32
// CHECK-DAG:     %[[CST:.*]] = arith.constant 1.000000e+00 : f32
// CHECK-DAG:     %[[SQRT:.*]] = math.sqrt %[[ARG]] : f32
// CHECK-DAG:     %[[DIV:.*]] = arith.divf %[[CST]], %[[SQRT]] : f32
// CHECK:         return %[[DIV]] : f32
func.func @rsqrt32(%float: f32) -> (f32)  {
  %float_result = math.rsqrt %float : f32
  return %float_result : f32
}

// -----

// CHECK-LABEL:   func.func @rsqrt
// CHECK-SAME:     (%[[ARG:.*]]: f64)
// CHECK-SAME:    -> f64
// CHECK-DAG:     %[[CST:.*]] = arith.constant 1.000000e+00 : f64
// CHECK-DAG:     %[[SQRT:.*]] = math.sqrt %[[ARG]] : f64
// CHECK-DAG:     %[[DIV:.*]] = arith.divf %[[CST]], %[[SQRT]] : f64
// CHECK:         return %[[DIV]] : f64
func.func @rsqrt64(%float: f64) -> (f64)  {
  %float_result = math.rsqrt %float : f64
  return %float_result : f64
}

// -----

// CHECK-LABEL:   func.func @rsqrt_vec
// CHECK-SAME:     (%[[ARG:.*]]: vector<5xf32>)
// CHECK-SAME:    -> vector<5xf32>
// CHECK-DAG:     %[[CST:.*]] = arith.constant dense<1.000000e+00> : vector<5xf32>
// CHECK-DAG:     %[[SQRT:.*]] = math.sqrt %[[ARG]] : vector<5xf32>
// CHECK-DAG:     %[[DIV:.*]] = arith.divf %[[CST]], %[[SQRT]] : vector<5xf32>
// CHECK:         return %[[DIV]] : vector<5xf32>
func.func @rsqrt_vec(%float: vector<5xf32>) -> (vector<5xf32>)  {
  %float_result = math.rsqrt %float : vector<5xf32>
  return %float_result : vector<5xf32>
}

// -----

// CHECK-LABEL:   func.func @rsqrt_tns
// CHECK-SAME:     (%[[ARG:.*]]: tensor<5x8xf32>)
// CHECK-SAME:    -> tensor<5x8xf32>
// CHECK-DAG:     %[[CST:.*]] = arith.constant dense<1.000000e+00> : tensor<5x8xf32>
// CHECK-DAG:     %[[SQRT:.*]] = math.sqrt %[[ARG]] : tensor<5x8xf32>
// CHECK-DAG:     %[[DIV:.*]] = arith.divf %[[CST]], %[[SQRT]] : tensor<5x8xf32>
// CHECK:         return %[[DIV]] : tensor<5x8xf32>
func.func @rsqrt_tns(%float: tensor<5x8xf32>) -> (tensor<5x8xf32>)  {
  %float_result = math.rsqrt %float : tensor<5x8xf32>
  return %float_result : tensor<5x8xf32>
}

// -----

// CHECK-LABEL:    func.func @non_static_shape_ceil_op
// CHECK-SAME:     (%[[ARG:.*]]: tensor<?xf32>)
// CHECK-SAME:     -> tensor<?xf32>
// CHECK:          %[[CEIL:.*]] = math.ceil %[[ARG]] : tensor<?xf32>
// CHECK:          return %[[CEIL]] : tensor<?xf32>

func.func @non_static_shape_ceil_op(%arg: tensor<?xf32>) -> tensor<?xf32>{
  %a = math.ceil %arg : tensor<?xf32>
  return %a: tensor<?xf32>
}

// -----

// CHECK-LABEL:    func.func @unranked_ceil_op
// CHECK-SAME:     (%[[ARG:.*]]: tensor<*xf32>)
// CHECK-SAME:     -> tensor<*xf32>
// CHECK:          %[[CEIL:.*]] = math.ceil %[[ARG]] : tensor<*xf32>
// CHECK:          return %[[CEIL]] : tensor<*xf32>

func.func @unranked_ceil_op(%arg: tensor<*xf32>) -> tensor<*xf32>{
  %a = math.ceil %arg : tensor<*xf32>
  return %a: tensor<*xf32>
}

// -----

// CHECK-LABEL:    func.func @non_static_shape_rsqrt_op
// CHECK-SAME:     (%[[ARG:.*]]: tensor<?xf32>)
// CHECK-SAME:     -> tensor<?xf32>
// CHECK:          %[[RSQRT:.*]] = math.rsqrt %[[ARG]] : tensor<?xf32>
// CHECK:          return %[[RSQRT]] : tensor<?xf32>

func.func @non_static_shape_rsqrt_op(%arg: tensor<?xf32>) -> tensor<?xf32>{
  %a = math.rsqrt %arg : tensor<?xf32>
  return %a: tensor<?xf32>
}

// -----

// CHECK-LABEL:    func.func @unranked_rsqrt_op
// CHECK-SAME:     (%[[ARG:.*]]: tensor<*xf32>)
// CHECK-SAME:     -> tensor<*xf32>
// CHECK:          %[[RSQRT:.*]] = math.rsqrt %[[ARG]] : tensor<*xf32>
// CHECK:          return %[[RSQRT]] : tensor<*xf32>

func.func @unranked_rsqrt_op(%arg: tensor<*xf32>) -> tensor<*xf32>{
  %a = math.rsqrt %arg : tensor<*xf32>
  return %a: tensor<*xf32>
}
