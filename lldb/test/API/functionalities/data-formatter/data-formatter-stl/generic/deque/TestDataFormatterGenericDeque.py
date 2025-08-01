import lldb
from lldbsuite.test.decorators import *
from lldbsuite.test.lldbtest import *
from lldbsuite.test import lldbutil


class GenericDequeDataFormatterTestCase(TestBase):
    def findVariable(self, name):
        var = self.frame().FindVariable(name)
        self.assertTrue(var.IsValid())
        return var

    def getVariableType(self, name):
        var = self.findVariable(name)
        return var.GetType().GetDisplayTypeName()

    def check_size(self, var_name, size):
        var = self.findVariable(var_name)
        self.assertEqual(var.GetNumChildren(), size)

    def check_numbers(self, var_name, show_ptr=False):
        patterns = []
        substrs = [
            "[0] = 1",
            "[1] = 12",
            "[2] = 123",
            "[3] = 1234",
            "[4] = 12345",
            "[5] = 123456",
            "[6] = 1234567",
            "}",
        ]
        if show_ptr:
            patterns = [var_name + " = 0x.* size=7"]
        else:
            substrs.insert(0, var_name + " = size=7")
        self.expect(
            "frame variable " + var_name,
            patterns=patterns,
            substrs=substrs,
        )
        self.expect_expr(
            var_name,
            result_summary="size=7",
            result_children=[
                ValueCheck(value="1"),
                ValueCheck(value="12"),
                ValueCheck(value="123"),
                ValueCheck(value="1234"),
                ValueCheck(value="12345"),
                ValueCheck(value="123456"),
                ValueCheck(value="1234567"),
            ],
        )

    def do_test(self):
        (_, process, _, bkpt) = lldbutil.run_to_source_breakpoint(
            self, "break here", lldb.SBFileSpec("main.cpp")
        )

        self.expect_expr("empty", result_children=[])
        self.expect_expr(
            "deque_1",
            result_children=[
                ValueCheck(name="[0]", value="1"),
            ],
        )
        self.expect_expr(
            "deque_3",
            result_children=[
                ValueCheck(name="[0]", value="3"),
                ValueCheck(name="[1]", value="1"),
                ValueCheck(name="[2]", value="2"),
            ],
        )

        self.check_size("deque_200_small", 200)
        for i in range(0, 100):
            self.expect_var_path(
                "deque_200_small[%d]" % (i),
                children=[
                    ValueCheck(name="a", value=str(-99 + i)),
                    ValueCheck(name="b", value=str(-100 + i)),
                    ValueCheck(name="c", value=str(-101 + i)),
                ],
            )
            self.expect_var_path(
                "deque_200_small[%d]" % (i + 100),
                children=[
                    ValueCheck(name="a", value=str(i)),
                    ValueCheck(name="b", value=str(1 + i)),
                    ValueCheck(name="c", value=str(2 + i)),
                ],
            )

        self.check_size("deque_200_large", 200)
        for i in range(0, 100):
            self.expect_var_path(
                "deque_200_large[%d]" % (i),
                children=[
                    ValueCheck(name="a", value=str(-99 + i)),
                    ValueCheck(name="b", value=str(-100 + i)),
                    ValueCheck(name="c", value=str(-101 + i)),
                    ValueCheck(name="d"),
                ],
            )
            self.expect_var_path(
                "deque_200_large[%d]" % (i + 100),
                children=[
                    ValueCheck(name="a", value=str(i)),
                    ValueCheck(name="b", value=str(1 + i)),
                    ValueCheck(name="c", value=str(2 + i)),
                    ValueCheck(name="d"),
                ],
            )

        lldbutil.continue_to_breakpoint(process, bkpt)

        # first value added
        self.expect("frame variable empty", substrs=["empty = size=1", "[0] = 1", "}"])

        # add remaining values
        lldbutil.continue_to_breakpoint(process, bkpt)

        self.check_numbers("empty")

        # clear out the deque
        lldbutil.continue_to_breakpoint(process, bkpt)

        self.expect_expr("empty", result_children=[])

    @add_test_categories(["libstdcxx"])
    def test_libstdcpp(self):
        self.build(dictionary={"USE_LIBSTDCPP": 1})
        self.do_test()

    @add_test_categories(["libc++"])
    def test_libcpp(self):
        self.build(dictionary={"USE_LIBCPP": 1})
        self.do_test()

    @add_test_categories(["msvcstl"])
    def test_msvcstl(self):
        # No flags, because the "msvcstl" category checks that the MSVC STL is used by default.
        self.build()
        self.do_test()

    def do_test_ref_and_ptr(self):
        """Test formatting of std::deque& and std::deque*"""
        (self.target, process, thread, bkpt) = lldbutil.run_to_source_breakpoint(
            self, "stop here", lldb.SBFileSpec("main.cpp", False)
        )

        # The reference should display the same was as the value did
        self.check_numbers("ref", True)

        # The pointer should just show the right number of elements:
        self.expect("frame variable ptr", substrs=["ptr =", " size=7"])
        self.expect("expression ptr", substrs=["$", "size=7"])

    @add_test_categories(["libstdcxx"])
    def test_libstdcpp_ref_and_ptr(self):
        self.build(dictionary={"USE_LIBSTDCPP": 1})
        self.do_test_ref_and_ptr()

    @add_test_categories(["libc++"])
    def test_libcpp_ref_and_ptr(self):
        self.build(dictionary={"USE_LIBCPP": 1})
        self.do_test_ref_and_ptr()

    @add_test_categories(["msvcstl"])
    def test_msvcstl_ref_and_ptr(self):
        self.build()
        self.do_test_ref_and_ptr()
