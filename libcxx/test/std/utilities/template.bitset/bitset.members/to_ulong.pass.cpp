//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// unsigned long to_ulong() const; // constexpr since C++23

#include <bitset>
#include <algorithm>
#include <type_traits>
#include <limits>
#include <climits>
#include <cassert>
#include <stdexcept>

#include "test_macros.h"

template <std::size_t N>
TEST_CONSTEXPR_CXX23 void test_to_ulong() {
  const std::size_t M   = sizeof(unsigned long) * CHAR_BIT < N ? sizeof(unsigned long) * CHAR_BIT : N;
  const bool is_M_zero  = std::integral_constant < bool, M == 0 > ::value; // avoid compiler warnings
  const std::size_t X   = is_M_zero ? sizeof(unsigned long) * CHAR_BIT - 1 : sizeof(unsigned long) * CHAR_BIT - M;
  const std::size_t max = is_M_zero ? 0 : std::size_t(std::numeric_limits<unsigned long>::max()) >> X;
  std::size_t tests[]   = {
      0,
      std::min<std::size_t>(1, max),
      std::min<std::size_t>(2, max),
      std::min<std::size_t>(3, max),
      std::min(max, max - 3),
      std::min(max, max - 2),
      std::min(max, max - 1),
      max};
  for (std::size_t j : tests) {
    std::bitset<N> v(j);
    assert(j == v.to_ulong());
  }

  { // test values bigger than can fit into the bitset
    const unsigned long val  = 0x5AFFFFA5UL;
    const bool canFit        = N < sizeof(unsigned long) * CHAR_BIT;
    const unsigned long mask = canFit ? (1UL << (canFit ? N : 0)) - 1 : (unsigned long)(-1); // avoid compiler warnings
    std::bitset<N> v(val);
    assert(v.to_ulong() == (val & mask)); // we shouldn't return bit patterns from outside the limits of the bitset.
  }
}

TEST_CONSTEXPR_CXX23 bool test() {
  test_to_ulong<0>();
  test_to_ulong<1>();
  test_to_ulong<31>();
  test_to_ulong<32>();
  test_to_ulong<33>();
  test_to_ulong<63>();
  test_to_ulong<64>();
  test_to_ulong<65>();
  test_to_ulong<1000>();

#ifndef TEST_HAS_NO_EXCEPTIONS
  if (!TEST_IS_CONSTANT_EVALUATED) {
    // bitset has true bits beyond the size of unsigned long
    std::bitset<std::numeric_limits<unsigned long>::digits + 1> q(0);
    q.flip();
    try {
      q.to_ulong(); // throws
      assert(false);
    } catch (const std::overflow_error&) {
      // expected
    } catch (...) {
      assert(false);
    }
  }
#endif // TEST_HAS_NO_EXCEPTIONS

  return true;
}

int main(int, char**) {
  test();
#if TEST_STD_VER > 20
  static_assert(test());
#endif

  return 0;
}
