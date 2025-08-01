//===- BufferizationToMemRef.cpp - Bufferization to MemRef conversion -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements patterns to convert Bufferization dialect to MemRef
// dialect.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/BufferizationToMemRef/BufferizationToMemRef.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {
#define GEN_PASS_DEF_CONVERTBUFFERIZATIONTOMEMREFPASS
#include "mlir/Conversion/Passes.h.inc"
} // namespace mlir

using namespace mlir;

namespace {
/// The CloneOpConversion transforms all bufferization clone operations into
/// memref alloc and memref copy operations. In the dynamic-shape case, it also
/// emits additional dim and constant operations to determine the shape. This
/// conversion does not resolve memory leaks if it is used alone.
struct CloneOpConversion : public OpConversionPattern<bufferization::CloneOp> {
  using OpConversionPattern<bufferization::CloneOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(bufferization::CloneOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op->getLoc();

    Type type = op.getType();
    Value alloc;

    if (auto unrankedType = dyn_cast<UnrankedMemRefType>(type)) {
      // Constants
      Value zero = arith::ConstantIndexOp::create(rewriter, loc, 0);
      Value one = arith::ConstantIndexOp::create(rewriter, loc, 1);

      // Dynamically evaluate the size and shape of the unranked memref
      Value rank = memref::RankOp::create(rewriter, loc, op.getInput());
      MemRefType allocType =
          MemRefType::get({ShapedType::kDynamic}, rewriter.getIndexType());
      Value shape = memref::AllocaOp::create(rewriter, loc, allocType, rank);

      // Create a loop to query dimension sizes, store them as a shape, and
      // compute the total size of the memref
      auto loopBody = [&](OpBuilder &builder, Location loc, Value i,
                          ValueRange args) {
        auto acc = args.front();
        auto dim = memref::DimOp::create(rewriter, loc, op.getInput(), i);

        memref::StoreOp::create(rewriter, loc, dim, shape, i);
        acc = arith::MulIOp::create(rewriter, loc, acc, dim);

        scf::YieldOp::create(rewriter, loc, acc);
      };
      auto size = scf::ForOp::create(rewriter, loc, zero, rank, one,
                                     ValueRange(one), loopBody)
                      .getResult(0);

      MemRefType memrefType = MemRefType::get({ShapedType::kDynamic},
                                              unrankedType.getElementType());

      // Allocate new memref with 1D dynamic shape, then reshape into the
      // shape of the original unranked memref
      alloc = memref::AllocOp::create(rewriter, loc, memrefType, size);
      alloc =
          memref::ReshapeOp::create(rewriter, loc, unrankedType, alloc, shape);
    } else {
      MemRefType memrefType = cast<MemRefType>(type);
      MemRefLayoutAttrInterface layout;
      auto allocType =
          MemRefType::get(memrefType.getShape(), memrefType.getElementType(),
                          layout, memrefType.getMemorySpace());
      // Since this implementation always allocates, certain result types of
      // the clone op cannot be lowered.
      if (!memref::CastOp::areCastCompatible({allocType}, {memrefType}))
        return failure();

      // Transform a clone operation into alloc + copy operation and pay
      // attention to the shape dimensions.
      SmallVector<Value, 4> dynamicOperands;
      for (int i = 0; i < memrefType.getRank(); ++i) {
        if (!memrefType.isDynamicDim(i))
          continue;
        Value dim = rewriter.createOrFold<memref::DimOp>(loc, op.getInput(), i);
        dynamicOperands.push_back(dim);
      }

      // Allocate a memref with identity layout.
      alloc =
          memref::AllocOp::create(rewriter, loc, allocType, dynamicOperands);
      // Cast the allocation to the specified type if needed.
      if (memrefType != allocType)
        alloc =
            memref::CastOp::create(rewriter, op->getLoc(), memrefType, alloc);
    }

    memref::CopyOp::create(rewriter, loc, op.getInput(), alloc);
    rewriter.replaceOp(op, alloc);
    return success();
  }
};

} // namespace

namespace {
struct BufferizationToMemRefPass
    : public impl::ConvertBufferizationToMemRefPassBase<
          BufferizationToMemRefPass> {
  BufferizationToMemRefPass() = default;

  void runOnOperation() override {
    if (!isa<ModuleOp, FunctionOpInterface>(getOperation())) {
      emitError(getOperation()->getLoc(),
                "root operation must be a builtin.module or a function");
      signalPassFailure();
      return;
    }

    bufferization::DeallocHelperMap deallocHelperFuncMap;
    if (auto module = dyn_cast<ModuleOp>(getOperation())) {
      OpBuilder builder = OpBuilder::atBlockBegin(module.getBody());

      // Build dealloc helper function if there are deallocs.
      getOperation()->walk([&](bufferization::DeallocOp deallocOp) {
        Operation *symtableOp =
            deallocOp->getParentWithTrait<OpTrait::SymbolTable>();
        if (deallocOp.getMemrefs().size() > 1 &&
            !deallocHelperFuncMap.contains(symtableOp)) {
          SymbolTable symbolTable(symtableOp);
          func::FuncOp helperFuncOp =
              bufferization::buildDeallocationLibraryFunction(
                  builder, getOperation()->getLoc(), symbolTable);
          deallocHelperFuncMap[symtableOp] = helperFuncOp;
        }
      });
    }

    RewritePatternSet patterns(&getContext());
    patterns.add<CloneOpConversion>(patterns.getContext());
    bufferization::populateBufferizationDeallocLoweringPattern(
        patterns, deallocHelperFuncMap);

    ConversionTarget target(getContext());
    target.addLegalDialect<memref::MemRefDialect, arith::ArithDialect,
                           scf::SCFDialect, func::FuncDialect>();
    target.addIllegalDialect<bufferization::BufferizationDialect>();

    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns))))
      signalPassFailure();
  }
};
} // namespace
