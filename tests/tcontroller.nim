import unittest, sequtils
import ../src/reversi
import ../src/controller


suite "reversi controller must":
    test "convert input to cell index":
        let converted = toCellIndex("A1")
        doAssert (0, 0) == converted

suite "minimax ai must":
    test "choose the most suitable move":
        var field: Field = [[Empty, Empty, Empty, White, Empty, Empty, Empty, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, White, White, Empty, Empty, Empty, Empty],
                            [Empty, White, Empty, White, Empty, Empty, Empty, Empty],
                            [Black, Empty, Empty, Black, White, Empty, Empty, Empty],
                            [Empty, White, Empty, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, White, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty]]
        let blackHole = (0, 0)
        let game = fromInitialCond(field, blackHole)
        let aiPlayer = newAiController(Black)
        doAssert "D8" == aiPlayer.getInput(game, aiPlayer.color)
        