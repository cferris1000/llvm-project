//===-- PythonTestSuite.cpp -----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "gtest/gtest.h"

#include "Plugins/ScriptInterpreter/Python/SWIGPythonBridge.h"
#include "Plugins/ScriptInterpreter/Python/lldb-python.h"

#include "PythonTestSuite.h"
#include <optional>

void PythonTestSuite::SetUp() {
  // Although we don't care about concurrency for the purposes of running
  // this test suite, Python requires the GIL to be locked even for
  // deallocating memory, which can happen when you call Py_DECREF or
  // Py_INCREF.  So acquire the GIL for the entire duration of this
  // test suite.
  Py_InitializeEx(0);
  m_gil_state = PyGILState_Ensure();
  PyRun_SimpleString("import sys");
}

void PythonTestSuite::TearDown() {
  PyGILState_Release(m_gil_state);

  // We could call Py_FinalizeEx here, but initializing and finalizing Python is
  // pretty slow, so just keep Python initialized across tests.
}

// The following functions are the Pythonic implementations of the required
// callbacks. Because they're defined in libLLDB which we cannot link for the
// unit test, we have a 'default' implementation here.

extern "C" PyObject *PyInit__lldb(void) { return nullptr; }

llvm::Expected<bool>
lldb_private::python::SWIGBridge::LLDBSwigPythonBreakpointCallbackFunction(
    const char *python_function_name, const char *session_dictionary_name,
    const lldb::StackFrameSP &sb_frame,
    const lldb::BreakpointLocationSP &sb_bp_loc,
    const StructuredDataImpl &args_impl) {
  return false;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonWatchpointCallbackFunction(
    const char *python_function_name, const char *session_dictionary_name,
    const lldb::StackFrameSP &sb_frame, const lldb::WatchpointSP &sb_wp) {
  return false;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonFormatterCallbackFunction(
    const char *python_function_name, const char *session_dictionary_name,
    lldb::TypeImplSP type_impl_sp) {
  return false;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonCallTypeScript(
    const char *python_function_name, const void *session_dictionary,
    const lldb::ValueObjectSP &valobj_sp, void **pyfunct_wrapper,
    const lldb::TypeSummaryOptionsSP &options_sp, std::string &retval) {
  return false;
}

python::PythonObject
lldb_private::python::SWIGBridge::LLDBSwigPythonCreateSyntheticProvider(
    const char *python_class_name, const char *session_dictionary_name,
    const lldb::ValueObjectSP &valobj_sp) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::LLDBSwigPythonCreateCommandObject(
    const char *python_class_name, const char *session_dictionary_name,
    lldb::DebuggerSP debugger_sp) {
  return python::PythonObject();
}

size_t lldb_private::python::SWIGBridge::LLDBSwigPython_CalculateNumChildren(
    PyObject *implementor, uint32_t max) {
  return 0;
}

PyObject *lldb_private::python::SWIGBridge::LLDBSwigPython_GetChildAtIndex(
    PyObject *implementor, uint32_t idx) {
  return nullptr;
}

int lldb_private::python::SWIGBridge::LLDBSwigPython_GetIndexOfChildWithName(
    PyObject *implementor, const char *child_name) {
  return 0;
}

void *
lldb_private::python::LLDBSWIGPython_CastPyObjectToSBData(PyObject *data) {
  return nullptr;
}

void *lldb_private::python::LLDBSWIGPython_CastPyObjectToSBBreakpoint(
    PyObject *data) {
  return nullptr;
}

void *lldb_private::python::LLDBSWIGPython_CastPyObjectToSBAttachInfo(
    PyObject *data) {
  return nullptr;
}

void *lldb_private::python::LLDBSWIGPython_CastPyObjectToSBLaunchInfo(
    PyObject *data) {
  return nullptr;
}

void *
lldb_private::python::LLDBSWIGPython_CastPyObjectToSBError(PyObject *data) {
  return nullptr;
}

void *
lldb_private::python::LLDBSWIGPython_CastPyObjectToSBEvent(PyObject *data) {
  return nullptr;
}

void *
lldb_private::python::LLDBSWIGPython_CastPyObjectToSBStream(PyObject *data) {
  return nullptr;
}

void *lldb_private::python::LLDBSWIGPython_CastPyObjectToSBSymbolContext(
    PyObject *data) {
  return nullptr;
}

void *
lldb_private::python::LLDBSWIGPython_CastPyObjectToSBValue(PyObject *data) {
  return nullptr;
}

void *lldb_private::python::LLDBSWIGPython_CastPyObjectToSBMemoryRegionInfo(
    PyObject *data) {
  return nullptr;
}

void *lldb_private::python::LLDBSWIGPython_CastPyObjectToSBExecutionContext(
    PyObject *data) {
  return nullptr;
}

lldb::ValueObjectSP
lldb_private::python::SWIGBridge::LLDBSWIGPython_GetValueObjectSPFromSBValue(
    void *data) {
  return nullptr;
}

bool lldb_private::python::SWIGBridge::
    LLDBSwigPython_UpdateSynthProviderInstance(PyObject *implementor) {
  return false;
}

bool lldb_private::python::SWIGBridge::
    LLDBSwigPython_MightHaveChildrenSynthProviderInstance(
        PyObject *implementor) {
  return false;
}

PyObject *
lldb_private::python::SWIGBridge::LLDBSwigPython_GetValueSynthProviderInstance(
    PyObject *implementor) {
  return nullptr;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonCallCommand(
    const char *python_function_name, const char *session_dictionary_name,
    lldb::DebuggerSP debugger, const char *args,
    lldb_private::CommandReturnObject &cmd_retobj,
    lldb::ExecutionContextRefSP exe_ctx_ref_sp) {
  return false;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonCallCommandObject(
    PyObject *implementor, lldb::DebuggerSP debugger, const char *args,
    lldb_private::CommandReturnObject &cmd_retobj,
    lldb::ExecutionContextRefSP exe_ctx_ref_sp) {
  return false;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonCallParsedCommandObject(
    PyObject *implementor, lldb::DebuggerSP debugger,
    StructuredDataImpl &args_impl,
    lldb_private::CommandReturnObject &cmd_retobj,
    lldb::ExecutionContextRefSP exe_ctx_ref_sp) {
  return false;
}

std::optional<std::string>
LLDBSwigPythonGetRepeatCommandForScriptedCommand(PyObject *implementor,
                                                 std::string &command) {
  return std::nullopt;
}

StructuredData::DictionarySP
LLDBSwigPythonHandleArgumentCompletionForScriptedCommand(
    PyObject *implementor, std::vector<llvm::StringRef> &args, size_t args_pos,
    size_t pos_in_arg) {
  return {};
}

StructuredData::DictionarySP
LLDBSwigPythonHandleOptionArgumentCompletionForScriptedCommand(
    PyObject *implementor, llvm::StringRef &long_options, size_t char_in_arg) {
  return {};
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonCallModuleInit(
    const char *python_module_name, const char *session_dictionary_name,
    lldb::DebuggerSP debugger) {
  return false;
}

bool lldb_private::python::SWIGBridge::LLDBSwigPythonCallModuleNewTarget(
    const char *python_module_name, const char *session_dictionary_name,
    lldb::TargetSP target) {
  return false;
}

python::PythonObject
lldb_private::python::SWIGBridge::LLDBSWIGPythonCreateOSPlugin(
    const char *python_class_name, const char *session_dictionary_name,
    const lldb::ProcessSP &process_sp) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::LLDBSWIGPython_CreateFrameRecognizer(
    const char *python_class_name, const char *session_dictionary_name) {
  return python::PythonObject();
}

PyObject *
lldb_private::python::SWIGBridge::LLDBSwigPython_GetRecognizedArguments(
    PyObject *implementor, const lldb::StackFrameSP &frame_sp) {
  return nullptr;
}

bool lldb_private::python::SWIGBridge::LLDBSWIGPythonRunScriptKeywordProcess(
    const char *python_function_name, const char *session_dictionary_name,
    const lldb::ProcessSP &process, std::string &output) {
  return false;
}

std::optional<std::string>
lldb_private::python::SWIGBridge::LLDBSWIGPythonRunScriptKeywordThread(
    const char *python_function_name, const char *session_dictionary_name,
    lldb::ThreadSP thread) {
  return std::nullopt;
}

bool lldb_private::python::SWIGBridge::LLDBSWIGPythonRunScriptKeywordTarget(
    const char *python_function_name, const char *session_dictionary_name,
    const lldb::TargetSP &target, std::string &output) {
  return false;
}

std::optional<std::string>
lldb_private::python::SWIGBridge::LLDBSWIGPythonRunScriptKeywordFrame(
    const char *python_function_name, const char *session_dictionary_name,
    lldb::StackFrameSP frame) {
  return std::nullopt;
}

bool lldb_private::python::SWIGBridge::LLDBSWIGPythonRunScriptKeywordValue(
    const char *python_function_name, const char *session_dictionary_name,
    const lldb::ValueObjectSP &value, std::string &output) {
  return false;
}

void *lldb_private::python::SWIGBridge::LLDBSWIGPython_GetDynamicSetting(
    void *module, const char *setting, const lldb::TargetSP &target_sp) {
  return nullptr;
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(Status &&status) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(lldb::ProcessAttachInfoSP) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(lldb::ProcessLaunchInfoSP) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(lldb::DataExtractorSP) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(lldb::ExecutionContextRefSP) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(lldb::ThreadPlanSP) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(lldb::ProcessSP) {
  return python::PythonObject();
}

python::PythonObject lldb_private::python::SWIGBridge::ToSWIGWrapper(
    const lldb_private::StructuredDataImpl &) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(Event *event) {
  return python::PythonObject();
}

python::PythonObject
lldb_private::python::SWIGBridge::ToSWIGWrapper(const Stream *stream) {
  return python::PythonObject();
}

python::PythonObject lldb_private::python::SWIGBridge::ToSWIGWrapper(
    std::shared_ptr<lldb::SBStream> stream_sb) {
  return python::PythonObject();
}
