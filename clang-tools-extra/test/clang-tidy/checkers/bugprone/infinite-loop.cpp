// RUN: %check_clang_tidy %s bugprone-infinite-loop %t \
// RUN:                   -- -- -fexceptions -fblocks -fno-delayed-template-parsing

void simple_infinite_loop1() {
  int i = 0;
  int j = 0;
  while (i < 10) {
  // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
    j++;
  }

  while (int k = 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; it does not check any variables in the condition [bugprone-infinite-loop]
    j--;
  }

  while (int k = 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; it does not check any variables in the condition [bugprone-infinite-loop]
    k--;
  }

  do {
  // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
    j++;
  } while (i < 10);

  for (i = 0; i < 10; ++j) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
  }
}

void simple_infinite_loop2() {
  int i = 0;
  int j = 0;
  int Limit = 10;
  while (i < Limit) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i, Limit) are updated in the loop body [bugprone-infinite-loop]
    j++;
  }

  while (int k = Limit) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (Limit) are updated in the loop body [bugprone-infinite-loop]
    j--;
  }

  while (int k = Limit) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (Limit) are updated in the loop body [bugprone-infinite-loop]
    k--;
  }

  do {
  // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i, Limit) are updated in the loop body [bugprone-infinite-loop]
    j++;
  } while (i < Limit);

  for (i = 0; i < Limit; ++j) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i, Limit) are updated in the loop body [bugprone-infinite-loop]
  }
}

void simple_not_infinite1() {
  int i = 0;
  int Limit = 100;
  while (i < Limit) {
    // Not an error since 'Limit' is updated.
    Limit--;
  }

  while (Limit--) {
    // Not an error since 'Limit' is updated.
    i++;
  }

  while ((Limit)--) {
    // Not an error since 'Limit' is updated.
    i++;
  }

  while ((Limit) -= 1) {
    // Not an error since 'Limit' is updated.
  }

  while (int k = Limit) {
    // Not an error since 'Limit' is updated.
    Limit--;
  }

  while (int k = Limit) {
    // Not an error since 'Limit' is updated
    (Limit)--;
  }

  while (int k = Limit--) {
    // Not an error since 'Limit' is updated.
    i++;
  }

  do {
    Limit--;
  } while (i < Limit);

  for (i = 0; i < Limit; Limit--) {
  }

  for (i = 0; i < Limit; (Limit) = Limit - 1) {
  }

  for (i = 0; i < Limit; (Limit) -= 1) {
  }

  for (i = 0; i < Limit; --(Limit)) {
  }
}

void simple_not_infinite2() {
  for (int i = 10; i-- > 0;) {
    // Not an error, since loop variable is modified in its condition part.
  }
}

int unknown_function();

void function_call() {
  int i = 0;
  while (i < unknown_function()) {
    // Not an error, since the function may return different values.
  }

  do {
    // Not an error, since the function may return different values.
  } while (i < unknown_function());

  for (i = 0; i < unknown_function();) {
    // Not an error, since the function may return different values.
  }
}

void escape_before1() {
  int i = 0;
  int Limit = 100;
  int *p = &i;
  while (i < Limit) {
    // Not an error, since *p is alias of i.
    (*p)++;
  }

  do {
    (*p)++;
  } while (i < Limit);

  for (i = 0; i < Limit; ++(*p)) {
  }
}

void escape_before2() {
  int i = 0;
  int Limit = 100;
  int &ii = i;
  while (i < Limit) {
    // Not an error, since ii is alias of i.
    ii++;
  }

  do {
    ii++;
  } while (i < Limit);

  for (i = 0; i < Limit; ++ii) {
  }
}

void escape_inside1() {
  int i = 0;
  int Limit = 100;
  int *p = &i;
  while (i < Limit) {
    // Not an error, since *p is alias of i.
    int *p = &i;
    (*p)++;
  }

  do {
    int *p = &i;
    (*p)++;
  } while (i < Limit);
}

void escape_inside2() {
  int i = 0;
  int Limit = 100;
  while (i < Limit) {
    // Not an error, since ii is alias of i.
    int &ii = i;
    ii++;
  }

  do {
    int &ii = i;
    ii++;
  } while (i < Limit);
}

void escape_after1() {
  int i = 0;
  int j = 0;
  int Limit = 10;

  while (i < Limit) {
    // False negative, but difficult to detect without CFG-based analysis
  }
  int *p = &i;
}

void escape_after2() {
  int i = 0;
  int j = 0;
  int Limit = 10;

  while (i < Limit) {
    // False negative, but difficult to detect without CFG-based analysis
  }
  int &ii = i;
}

int glob;

void global1(int &x) {
  int i = 0, Limit = 100;
  while (x < Limit) {
    // Not an error since 'x' can be an alias of 'glob'.
    glob++;
  }
}

void global2() {
  int i = 0, Limit = 100;
  while (glob < Limit) {
    // Since 'glob' is declared out of the function we do not warn.
    i++;
  }
}

struct X {
  int m;

  void change_m();

  void member_expr1(int i) {
    while (i < m) {
      // False negative: No warning, since skipping the case where a struct or
      // class can be found in its condition.
      ;
    }
  }

  void member_expr2(int i) {
    while (i < m) {
      --m;
    }
  }

  void member_expr3(int i) {
    while (i < m) {
      change_m();
    }
  }
};

void array_index() {
  int i = 0;
  int v[10];
  while (i < 10) {
    v[i++] = 0;
  }

  i = 0;
  do {
    v[i++] = 0;
  } while (i < 9);

  for (i = 0; i < 10;) {
    v[i++] = 0;
  }

  for (i = 0; i < 10; v[i++] = 0) {
  }
}

void no_loop_variable() {
  while (0)
    ;
}

void volatile_in_condition() {
  volatile int cond = 0;
  while (!cond) {
  }
}

namespace std {
template<typename T> class atomic {
  T val;
public:
  atomic(T v): val(v) {};
  operator T() { return val; };
};
}

void atomic_in_condition() {
  std::atomic<int> cond = 0;
  while (!cond) {
  }
}

void loop_exit1() {
  int i = 0;
  while (i) {
    if (unknown_function())
      break;
  }
}

void loop_exit2() {
  int i = 0;
  while (i) {
    if (unknown_function())
      return;
  }
}

void loop_exit3() {
  int i = 0;
  while (i) {
    if (unknown_function())
      goto end;
  }
 end:
  ;
}

void loop_exit4() {
  int i = 0;
  while (i) {
    if (unknown_function())
      throw 1;
  }
}

[[noreturn]] void exit(int);

void loop_exit5() {
  int i = 0;
  while (i) {
    if (unknown_function())
      exit(1);
  }
}

void loop_exit_in_lambda() {
  int i = 0;
  while (i) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
    auto l = []() { return 0; };
  }
}

void lambda_capture() {
  int i = 0;
  int Limit = 100;
  int *p = &i;
  while (i < Limit) {
    // Not an error, since i is captured by reference in a lambda.
    auto l = [&i]() { ++i; };
  }

  do {
    int *p = &i;
    (*p)++;
  } while (i < Limit);
}

template <typename T> void accept_callback(T t) {
  // Potentially call the callback.
  // Possibly on a background thread or something.
}

void accept_block(void (^)(void)) {
  // Potentially call the callback.
  // Possibly on a background thread or something.
}

void wait(void) {
  // Wait for the previously passed callback to be called.
}

void lambda_capture_from_outside() {
  bool finished = false;
  accept_callback([&]() {
    finished = true;
  });
  while (!finished) {
    wait();
  }
}

void lambda_capture_from_outside_by_value() {
  bool finished = false;
  accept_callback([finished]() {
    if (finished) {}
  });
  while (!finished) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (finished) are updated in the loop body [bugprone-infinite-loop]
    wait();
  }
}

void lambda_capture_from_outside_but_unchanged() {
  bool finished = false;
  accept_callback([&finished]() {
    if (finished) {}
  });
  while (!finished) {
    // FIXME: Should warn.
    wait();
  }
}

void block_capture_from_outside() {
  __block bool finished = false;
  accept_block(^{
    finished = true;
  });
  while (!finished) {
    wait();
  }
}

void block_capture_from_outside_by_value() {
  bool finished = false;
  accept_block(^{
    if (finished) {}
  });
  while (!finished) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (finished) are updated in the loop body [bugprone-infinite-loop]
    wait();
  }
}

void block_capture_from_outside_but_unchanged() {
  __block bool finished = false;
  accept_block(^{
    if (finished) {}
  });
  while (!finished) {
    // FIXME: Should warn.
    wait();
  }
}

void finish_at_any_time(bool *finished);

void lambda_capture_with_loop_inside_lambda_bad() {
  bool finished = false;
  auto lambda = [=]() {
    while (!finished) {
      // CHECK-MESSAGES: :[[@LINE-1]]:5: warning: this loop is infinite; none of its condition variables (finished) are updated in the loop body [bugprone-infinite-loop]
      wait();
    }
  };
  finish_at_any_time(&finished);
  lambda();
}

void lambda_capture_with_loop_inside_lambda_bad_init_capture() {
  bool finished = false;
  auto lambda = [captured_finished=finished]() {
    while (!captured_finished) {
      // CHECK-MESSAGES: :[[@LINE-1]]:5: warning: this loop is infinite; none of its condition variables (captured_finished) are updated in the loop body [bugprone-infinite-loop]
      wait();
    }
  };
  finish_at_any_time(&finished);
  lambda();
}

void lambda_capture_with_loop_inside_lambda_good() {
  bool finished = false;
  auto lambda = [&]() {
    while (!finished) {
      wait(); // No warning: the variable may be updated
              // from outside the lambda.
    }
  };
  finish_at_any_time(&finished);
  lambda();
}

void lambda_capture_with_loop_inside_lambda_good_init_capture() {
  bool finished = false;
  auto lambda = [&captured_finished=finished]() {
    while (!captured_finished) {
      wait(); // No warning: the variable may be updated
              // from outside the lambda.
    }
  };
  finish_at_any_time(&finished);
  lambda();
}

void block_capture_with_loop_inside_block_bad() {
  bool finished = false;
  auto block = ^() {
    while (!finished) {
      // CHECK-MESSAGES: :[[@LINE-1]]:5: warning: this loop is infinite; none of its condition variables (finished) are updated in the loop body [bugprone-infinite-loop]
      wait();
    }
  };
  finish_at_any_time(&finished);
  block();
}

void block_capture_with_loop_inside_block_bad_simpler() {
  bool finished = false;
  auto block = ^() {
    while (!finished) {
      // CHECK-MESSAGES: :[[@LINE-1]]:5: warning: this loop is infinite; none of its condition variables (finished) are updated in the loop body [bugprone-infinite-loop]
      wait();
    }
  };
  block();
}

void block_capture_with_loop_inside_block_good() {
  __block bool finished = false;
  auto block = ^() {
    while (!finished) {
      wait(); // No warning: the variable may be updated
              // from outside the block.
    }
  };
  finish_at_any_time(&finished);
  block();
}

void evaluatable(bool CondVar) {
  for (; false && CondVar;) {
  }
  while (false && CondVar) {
  }
  do {
  } while (false && CondVar);
}

struct logger {
  void (*debug)(struct logger *, const char *, ...);
};

int foo(void) {
  struct logger *pl = 0;
  int iterator = 0;
  while (iterator < 10) {
    char *l_tmp_msg = 0;
    pl->debug(pl, "%d: %s\n", iterator, l_tmp_msg);
    iterator++;
  }
  return 0;
}

struct AggregateWithReference {
  int &y;
};

void test_structured_bindings_good() {
  int x = 0;
  AggregateWithReference ref { x };
  auto &[y] = ref;
  for (; x < 10; ++y) {
    // No warning. The loop is finite because 'y' is a reference to 'x'.
  }
}

struct AggregateWithValue {
  int y;
};

void test_structured_bindings_bad() {
  int x = 0;
  AggregateWithValue val { x };
  auto &[y] = val;
  for (; x < 10; ++y) {
      // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (x) are updated in the loop body [bugprone-infinite-loop]
  }
}

void test_volatile_cast() {
  // This is a no-op cast. Clang ignores the qualifier, we should too.
  for (int i = 0; (volatile int)i < 10;) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
  }
}

void test_volatile_concrete_address(int i, int size) {
  // No warning. The value behind the volatile concrete address
  // is beyond our control. It may change at any time.
  for (; *((volatile int *)0x1234) < size;) {
  }

  for (; *((volatile int *)(0x1234 + i)) < size;) {
  }

  for (; **((volatile int **)0x1234) < size;) {
  }

  volatile int *x = (volatile int *)0x1234;
  for (; *x < 10;) {
  }

  // FIXME: This one should probably also be suppressed.
  // Whatever the developer is doing here, they can do that again anywhere else
  // which basically makes it a global.
  for (; *(int *)0x1234 < size;) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (size) are updated in the loop body [bugprone-infinite-loop]
  }
}

template <typename T>
int some_template_fn() { return 1; }

template <typename T>
void test_dependent_condition() {
  const int error = some_template_fn<T>();
  do {
  } while (false && error == 0);

  const int val = some_template_fn<T>();
  for (; !(val == 0 || true);) {
  }

  const int val2 = some_template_fn<T>();
  for (; !(val2 == 0 || false);) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (val2) are updated in the loop body [bugprone-infinite-loop]
  }

  const int val3 = some_template_fn<T>();
  do {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (val3) are updated in the loop body [bugprone-infinite-loop]
  } while (1, (true) && val3 == 1);

  const int val4 = some_template_fn<T>();
  do {
  } while (1, (false) && val4 == 1);
}

void test_typeof() {
  __typeof__({
    for (int i = 0; i < 10; ++i) {
    }
    0;
  }) x;
}

void test_typeof_infinite() {
  __typeof__({
    for (int i = 0; i < 10;) {
    }
    0;
  }) x;
}

void test_typeof_while_infinite() {
  __typeof__({
    int i = 0;
    while (i < 10) {
    }
    0;
  }) x;
}

void test_typeof_dowhile_infinite() {
  __typeof__({
    int i = 0;
    do {

    } while (i < 10);
    0;
  }) x;
}

void test_local_static_recursion() {
  static int i = 10;
  int j = 0;

  i--;
  while (i >= 0)
    test_local_static_recursion(); // no warning, recursively decrement i
  for (; i >= 0;)
    test_local_static_recursion(); // no warning, recursively decrement i
  for (; i + j >= 0;)
    test_local_static_recursion(); // no warning, recursively decrement i
  for (; i >= 0; i--)
    ; // no warning, i decrements
  while (j >= 0)
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (j) are updated in the loop body [bugprone-infinite-loop]
    test_local_static_recursion();

  int (*p)(int) = 0;

  while (i >= 0)
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
    p = 0;
  while (i >= 0)
    p(0); // we don't know what p points to so no warning
}

struct PairVal {
  int a;
  int b;
  PairVal(int a, int b) : a(a), b(b) {}
};

void structured_binding_infinite_loop1() {
  auto [x, y] = PairVal(0, 0);
  while (x < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (x) are updated in the loop body [bugprone-infinite-loop]
    y++;
  }
  while (y < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (y) are updated in the loop body [bugprone-infinite-loop]
    x++;
  }
}

void structured_binding_infinite_loop2() {
  auto [x, y] = PairVal(0, 0);
  while (x < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (x) are updated in the loop body [bugprone-infinite-loop]
    // No update to x or y
  }
  while (y < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (y) are updated in the loop body [bugprone-infinite-loop]
    // No update to x or y
  }
}

void structured_binding_not_infinite1() {
  auto [x, y] = PairVal(0, 0);
  while (x < 10) {
    x++;
  }
  while (y < 10) {
    y++;
  }
}

void volatile_structured_binding_in_condition() {
  volatile auto [x, y] = PairVal(0, 0);
  while (!x) {}
}

void test_local_static_structured_binding_recursion() {
  static auto [i, _] = PairVal(0, 0);
  int j = 0;

  i--;
  while (i >= 0)
    test_local_static_structured_binding_recursion(); // no warning, recursively decrement i
  for (; i >= 0;)
    test_local_static_structured_binding_recursion(); // no warning, recursively decrement i
  for (; i + j >= 0;)
    test_local_static_structured_binding_recursion(); // no warning, recursively decrement i
  for (; i >= 0; i--)
    ; // no warning, i decrements
  while (j >= 0)
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (j) are updated in the loop body [bugprone-infinite-loop]
    test_local_static_structured_binding_recursion();

  int (*p)(int) = 0;

  while (i >= 0)
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (i) are updated in the loop body [bugprone-infinite-loop]
    p = 0;
  while (i >= 0)
    p(0); // we don't know what p points to so no warning
}

struct S { int a; };
void issue_138842_reduced() {
    int x = 10;
    auto [y] = S{1};

    while (y < x) {
      y++;
    }
}

namespace std {
template <typename T, typename U>
struct pair {
  T first;
  U second;

  pair(T a, U b) : first(a), second(b) {}
};
}

template <typename T, typename U>
void structured_binding_in_template_byval(T a, U b) {
  auto [c, d] = std::pair<T, U>(a,b);

  while (c < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (c) are updated in the loop body [bugprone-infinite-loop]
    d++;
  }

  while (c < 10) {
    c++; // no warning
  }
}

template <typename T, typename U>
void structured_binding_in_template_bylref(T a, U b) {
  auto p = std::pair<T, U>(a,b);
  auto& [c, d] = p;

  while (c < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (c) are updated in the loop body [bugprone-infinite-loop]
    d++;
  }

  while (c < 10) {
    c++; // no warning
  }
}

template <typename T, typename U>
void structured_binding_in_template_byrref(T a, U b) {
  auto p = std::pair<T, U>(a,b);
  auto&& [c, d] = p;

  while (c < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (c) are updated in the loop body [bugprone-infinite-loop]
    d++;
  }

  while (c < 10) {
    c++; // no warning
  }
}

void structured_binding_in_template_instantiation(int b) {
  structured_binding_in_template_byval(b, 0);
  structured_binding_in_template_bylref(b, 0);
  structured_binding_in_template_byrref(b, 0);
}

void array_structured_binding() {
  int arr[2] = {0, 0};
  auto [x, y] = arr;

  while (x < 10) {
    // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: this loop is infinite; none of its condition variables (x) are updated in the loop body [bugprone-infinite-loop]
    y++;
  }

  while (y < 10) {
    y++; // no warning
  }
}

namespace std {
    using size_t = int;
    template <class> struct tuple_size;
    template <std::size_t, class> struct tuple_element;
    template <class...> class tuple;

namespace {
    template <class T, T v>
    struct size_helper { static const T value = v; };
} // namespace

template <class... T>
struct tuple_size<tuple<T...>> : size_helper<std::size_t, sizeof...(T)> {};

template <std::size_t I, class... T>
struct tuple_element<I, tuple<T...>> {
    using type =  __type_pack_element<I, T...>;
};

template <class...> class tuple {};

template <std::size_t I, class... T>
typename tuple_element<I, tuple<T...>>::type get(tuple<T...>);
} // namespace std

std::tuple<int*, int> &get_chunk();

void test_structured_bindings_tuple() {
  auto [buffer, size ] = get_chunk();
  int maxLen = 8;

  while (size < maxLen) {
    // No warning. The loop is finite because 'size' is being incremented in each iteration and compared against 'maxLen' for termination
    buffer[size++] = 2;
  }
}

void test_structured_bindings_tuple_ref() {
  auto& [buffer, size ] = get_chunk();
  int maxLen = 8;

  while (size < maxLen) {
    // No warning. The loop is finite because 'size' is being incremented in each iteration and compared against 'maxLen' for termination
    buffer[size++] = 2;
  }
}
