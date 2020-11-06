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
        let rootGame = fromInitialCond(field, blackHole)
        let rootMoves = rootGame.getAvailableMovesForColor(Black)
        let levelOneGames = @[deepCopy(rootGame)].cycle(len(rootMoves))
        for i in 0..<len(rootMoves):
            levelOneGames[i].makeTurn(rootMoves[i], Black)

        var levelOneMoves: seq[seq[CellIndex]]
        for game in levelOneGames:
            levelOneMoves.add(game.getAvailableMovesForColor(White))

        var levelOneGameCopiesToMoves: seq[seq[Reversi]]
        for i in 0..<3:
            let movesPerGame = levelOneMoves[i]
            var gamesBranch: seq[Reversi]
            for j in 0..<len(movesPerGame):
                gamesBranch.add(deepCopy(levelOneGames[i]))
            levelOneGameCopiesToMoves.add(gamesBranch)
        
        var levelTwoGames: seq[Reversi]
        for i in 0..<len(levelOneGameCopiesToMoves):
            for j in 0..<len(levelOneGameCopiesToMoves[i]):
                levelOneGameCopiesToMoves[i][j].makeTurn(levelOneMoves[i][j], White)
                levelTwoGames.add(levelOneGameCopiesToMoves[i][j])
        doAssert 5 == len(levelTwoGames)
        