//===- unittests/Interpreter/InterpreterExceptionTest.cpp -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Unit tests for Clang's Interpreter library.
//
//===----------------------------------------------------------------------===//

#include "clang/Interpreter/Interpreter.h"

#include "clang/AST/ASTContext.h"
#include "clang/AST/Decl.h"
#include "clang/AST/DeclGroup.h"
#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/Version.h"
#include "clang/Config/config.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/TargetSelect.h"

#include "gmock/gmock.h"
#include "gtest/gtest.h"

// Disable LSan for this test.
// FIXME: Re-enable once we can assume GCC 13.2 or higher.
// https://llvm.org/github.com/llvm/llvm-project/issues/67586.
#if LLVM_ADDRESS_SANITIZER_BUILD || LLVM_HWADDRESS_SANITIZER_BUILD
#include <sanitizer/lsan_interface.h>
LLVM_ATTRIBUTE_USED int __lsan_is_turned_off() { return 1; }
#endif

#if defined(_AIX) || defined(__MVS__)
#define CLANG_INTERPRETER_PLATFORM_CANNOT_CREATE_LLJIT
#endif

using namespace clang;

namespace {
using Args = std::vector<const char *>;
static std::unique_ptr<Interpreter>
createInterpreter(const Args &ExtraArgs = {},
                  DiagnosticConsumer *Client = nullptr) {
  Args ClangArgs = {"-Xclang", "-emit-llvm-only"};
  llvm::append_range(ClangArgs, ExtraArgs);
  auto CB = clang::IncrementalCompilerBuilder();
  CB.SetCompilerArgs(ClangArgs);
  auto CI = cantFail(CB.CreateCpp());
  if (Client)
    CI->getDiagnostics().setClient(Client, /*ShouldOwnClient=*/false);
  return cantFail(clang::Interpreter::create(std::move(CI)));
}

#ifdef CLANG_INTERPRETER_PLATFORM_CANNOT_CREATE_LLJIT
TEST(InterpreterExceptionTest, DISABLED_CatchException) {
#else
TEST(InterpreterExceptionTest, CatchException) {
#endif
  llvm::llvm_shutdown_obj Y; // Call llvm_shutdown() on exit.
  llvm::InitializeNativeTarget();
  llvm::InitializeNativeTargetAsmPrinter();

  {
    auto J = llvm::orc::LLJITBuilder().create();
    if (!J) {
      // The platform does not support JITs.
      // Using llvm::consumeError will require typeinfo for ErrorInfoBase, we
      // can avoid that by going via the C interface.
      LLVMConsumeError(llvm::wrap(J.takeError()));
      GTEST_SKIP();
    }
  }

#define Stringify(s) Stringifyx(s)
#define Stringifyx(s) #s

  // We define a custom exception to avoid #include-ing the <exception> header
  // which would require this test to know about the libstdc++ location.
  // its own header file.
#define CUSTOM_EXCEPTION                                                       \
  struct custom_exception {                                                    \
    custom_exception(const char *Msg) : Message(Msg) {}                        \
    const char *Message;                                                       \
  };

  CUSTOM_EXCEPTION;

  std::string ExceptionCode = Stringify(CUSTOM_EXCEPTION);
  ExceptionCode +=
      R"(
extern "C" int printf(const char*, ...);
static void ThrowerAnError(const char* Name) {
  throw custom_exception(Name);
}

extern "C" int throw_exception() {
  try {
    ThrowerAnError("To be caught in JIT");
  } catch (const custom_exception& E) {
    printf("Caught: '%s'\n", E.Message);
  } catch (...) {
    printf("Unknown exception\n");
  }
  ThrowerAnError("To be caught in binary");
  return 0;
}
    )";
  std::unique_ptr<Interpreter> Interp = createInterpreter();
  // FIXME: Re-enable the excluded target triples.
  const clang::CompilerInstance *CI = Interp->getCompilerInstance();
  const llvm::Triple &Triple = CI->getASTContext().getTargetInfo().getTriple();

  // FIXME: ARM fails due to `Not implemented relocation type!`
  if (Triple.isARM())
    GTEST_SKIP();

  // FIXME: libunwind on darwin is broken, see PR49692.
  if (Triple.isOSDarwin() && (Triple.getArch() == llvm::Triple::aarch64 ||
                              Triple.getArch() == llvm::Triple::aarch64_32))
    GTEST_SKIP();

  llvm::cantFail(Interp->ParseAndExecute(ExceptionCode));
  testing::internal::CaptureStdout();
  auto ThrowException =
      llvm::cantFail(Interp->getSymbolAddress("throw_exception"))
          .toPtr<int (*)()>();
  EXPECT_ANY_THROW(ThrowException());
  std::string CapturedStdOut = testing::internal::GetCapturedStdout();
  EXPECT_EQ(CapturedStdOut, "Caught: 'To be caught in JIT'\n");
}

} // end anonymous namespace
