import unittest
import ../src/reversi
import ../src/controller


suite "reversi controller must":
    test "convert input to cell index":
        let converted = toCellIndex("A1")
        doAssert (0, 0) == converted

suite "minimax ai must":
    test "pass if there are no available moves":
        var field: Field = [[Empty, Empty, Empty, Empty, Empty, Empty, Black, White],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Black, Black],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Black, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty],
                            [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty]]
        let blackHole = (0, 0)
        let game = fromInitialCond(field, blackHole)
        let aiPlayer = newAiController(Black)
        doAssert "pass" == aiPlayer.getInput(game, aiPlayer.color)                   

    test "choose the most winning move":
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
        let aiPlayerBlack = newAiController(Black)
        doAssert "F5" == aiPlayerBlack.getInput(game, aiPlayerBlack.color)
        let aiPlayerWhite = newAiController(White)
        doAssert "D6" == aiPlayerWhite.getInput(game, aiPlayerWhite.color)
