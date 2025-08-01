// RUN: mkdir -p %t.dir/compilation-database-test/include
// RUN: mkdir -p %t.dir/compilation-database-test/a
// RUN: mkdir -p %t.dir/compilation-database-test/b
// RUN: echo 'int *AA = 0;' > %t.dir/compilation-database-test/a/a.cpp
// RUN: echo 'int *AB = 0;' > %t.dir/compilation-database-test/a/b.cpp
// RUN: echo 'int *BB = 0;' > %t.dir/compilation-database-test/b/b.cpp
// RUN: echo 'int *BC = 0;' > %t.dir/compilation-database-test/b/c.cpp
// RUN: echo 'int *BD = 0;' > %t.dir/compilation-database-test/b/d.cpp
// RUN: echo 'int *HP = 0;' > %t.dir/compilation-database-test/include/header.h
// RUN: echo '#include "header.h"' > %t.dir/compilation-database-test/include.cpp
// RUN: sed 's|test_dir|%/t.dir/compilation-database-test|g' %S/Inputs/compilation-database/template.json > %t.dir/compile_commands.json

// Regression test: shouldn't crash.
// RUN: not clang-tidy --checks=-*,modernize-use-nullptr -p %t.dir %t.dir/compilation-database-test/b/not-exist -header-filter=.* 2>&1 | FileCheck %s -check-prefix=CHECK-NOT-EXIST
// CHECK-NOT-EXIST: Error while processing {{.*[/\\]}}not-exist.
// CHECK-NOT-EXIST: unable to handle compilation
// CHECK-NOT-EXIST: Found compiler error

// RUN: clang-tidy --checks=-*,modernize-use-nullptr -p %t.dir %t.dir/compilation-database-test/a/a.cpp %t.dir/compilation-database-test/a/b.cpp %t.dir/compilation-database-test/b/b.cpp %t.dir/compilation-database-test/b/c.cpp %t.dir/compilation-database-test/b/d.cpp %t.dir/compilation-database-test/include.cpp -header-filter=.* -fix
// RUN: FileCheck -input-file=%t.dir/compilation-database-test/a/a.cpp %s -check-prefix=CHECK-FIX1
// RUN: FileCheck -input-file=%t.dir/compilation-database-test/a/b.cpp %s -check-prefix=CHECK-FIX2
// RUN: FileCheck -input-file=%t.dir/compilation-database-test/b/b.cpp %s -check-prefix=CHECK-FIX3
// RUN: FileCheck -input-file=%t.dir/compilation-database-test/b/c.cpp %s -check-prefix=CHECK-FIX4
// RUN: FileCheck -input-file=%t.dir/compilation-database-test/b/d.cpp %s -check-prefix=CHECK-FIX5
// RUN: FileCheck -input-file=%t.dir/compilation-database-test/include/header.h %s -check-prefix=CHECK-FIX6

// CHECK-FIX1: int *AA = nullptr;
// CHECK-FIX2: int *AB = nullptr;
// CHECK-FIX3: int *BB = nullptr;
// CHECK-FIX4: int *BC = nullptr;
// CHECK-FIX5: int *BD = nullptr;
// CHECK-FIX6: int *HP = nullptr;
