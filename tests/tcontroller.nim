import unittest
import ../src/controller

suite "reversi controller test suite":
    test "convert input to cell index":
        let converted = toCellIndex("A1")
        doAssert (0, 0) == converted
