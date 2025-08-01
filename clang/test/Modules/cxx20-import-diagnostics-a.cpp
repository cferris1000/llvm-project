// RUN: rm -rf %t
// RUN: mkdir -p %t
// RUN: split-file %s %t

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu1.cpp \
// RUN:  -o %t/B.pcm

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu2.cpp \
// RUN:  -o %t/C.pcm

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu3.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -fmodule-file=C=%t/C.pcm -o %t/AOK1.pcm

// RUN: %clang_cc1 -std=c++20 -S %t/import-diags-tu4.cpp \
// RUN:  -fmodule-file=AOK1=%t/AOK1.pcm -fmodule-file=B=%t/B.pcm \
// RUN:  -fmodule-file=C=%t/C.pcm -o %t/tu_3.s -verify

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu5.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -fmodule-file=C=%t/C.pcm -o %t/BC.pcm -verify

// RUN: %clang_cc1 -std=c++20 -S %t/import-diags-tu6.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -fmodule-file=C=%t/C.pcm -o %t/tu_5.s -verify

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu7.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -o %t/D.pcm -verify

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu8.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -o %t/D.pcm -verify

// RUN: %clang_cc1 -std=c++20 -S %t/import-diags-tu9.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -o %t/tu_8.s -verify

// RUN: %clang_cc1 -std=c++20 -emit-module-interface %t/import-diags-tu10.cpp \
// RUN:  -o %t/B.pcm -verify

// RUN: %clang_cc1 -std=c++20 -emit-obj %t/import-diags-tu11.cpp \
// RUN:  -fmodule-file=C=%t/C.pcm  -o %t/impl.o

// Test again with reduced BMI.
// RUN: rm -rf %t
// RUN: mkdir -p %t
// RUN: split-file %s %t

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu1.cpp \
// RUN:  -o %t/B.pcm

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu2.cpp \
// RUN:  -o %t/C.pcm

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu3.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -fmodule-file=C=%t/C.pcm -o %t/AOK1.pcm

// RUN: %clang_cc1 -std=c++20 -S %t/import-diags-tu4.cpp \
// RUN:  -fmodule-file=AOK1=%t/AOK1.pcm -fmodule-file=B=%t/B.pcm \
// RUN:  -fmodule-file=C=%t/C.pcm -o %t/tu_3.s -verify

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu5.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -fmodule-file=C=%t/C.pcm -o %t/BC.pcm -verify

// RUN: %clang_cc1 -std=c++20 -S %t/import-diags-tu6.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -fmodule-file=C=%t/C.pcm -o %t/tu_5.s -verify

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu7.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -o %t/D.pcm -verify

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu8.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -o %t/D.pcm -verify

// RUN: %clang_cc1 -std=c++20 -S %t/import-diags-tu9.cpp \
// RUN:  -fmodule-file=B=%t/B.pcm -o %t/tu_8.s -verify

// RUN: %clang_cc1 -std=c++20 -emit-reduced-module-interface %t/import-diags-tu10.cpp \
// RUN:  -o %t/B.pcm -verify

// RUN: %clang_cc1 -std=c++20 -emit-obj %t/import-diags-tu11.cpp \
// RUN:  -fmodule-file=C=%t/C.pcm  -o %t/impl.o

// Test diagnostics for incorrect module import sequences.

//--- import-diags-tu1.cpp

export module B;

int foo ();

// expected-no-diagnostics

//--- import-diags-tu2.cpp

export module C;

int bar ();

// expected-no-diagnostics

//--- import-diags-tu3.cpp

export module AOK1;

import B;
export import C;

export int theAnswer ();

// expected-no-diagnostics

//--- import-diags-tu4.cpp

module;

module AOK1;

export import C; // expected-error {{export declaration can only be used within a module interface}}

int theAnswer () { return 42; }

//--- import-diags-tu5.cpp

export module BC;

export import B;

int foo () { return 10; }

import C; // expected-error {{imports must immediately follow the module declaration}}

//--- import-diags-tu6.cpp

module B; // implicitly imports B.

int foo () { return 10; }

import C; // expected-error {{imports must immediately follow the module declaration}}

//--- import-diags-tu7.cpp

module;
// We can only have preprocessor directives here, which permits
// header units (include-translated or not) and named modules.
import B;
export module D;

int delta ();
// expected-no-diagnostics

//--- import-diags-tu8.cpp

export module D;

int delta ();

module :private;

import B; // expected-error {{imports must immediately follow the module declaration}}

//--- import-diags-tu9.cpp

module B;

import B; // expected-error {{import of module 'B' appears within its own implementation}}

//--- import-diags-tu10.cpp

export module B;

import B; // expected-error {{import of module 'B' appears within its own interface}}

//--- import-diags-tu11.cpp

int x;

import C;

int baz() { return 6174; }

// expected-no-diagnostics
