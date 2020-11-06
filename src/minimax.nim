import sugar, sequtils
import reversi

proc copyGameWithMovesMadeBy(game: Reversi, color: char): seq[Reversi] = 
    let moves = game.getAvailableMovesFor(color)
    for i in 0..<len(moves):
        result.add(deepCopy(game))
        result[i].makeTurn(moves[i], color)

type MinimaxTree = ref object
    value*: int
    move*: CellIndex
    body*: seq[MinimaxTree]

proc newMinimaxTree(): MinimaxTree =
    return MinimaxTree(value: -1, move: InvalidCell, body: @[])

proc getMoveWithMaxValue*(trees: seq[MinimaxTree]): CellIndex = 
    var value = 0
    for i in 0..<len(trees):
        if value < trees[i].value:
            value = trees[i].value
            result = trees[i].move

proc minimax*(game: Reversi, color: char, depth: int): MinimaxTree =
    proc min(s: seq[MinimaxTree]): MinimaxTree =
        result = s[minIndex(map(s, (a) => a.value))]

    let inverse = inverseof(color)
    let tree = newMinimaxTree()
    let moves = game.getAvailableMovesFor(color)
    if len(moves) == 0 or depth == 0:
        return tree

    let level = game.copyGameWithMovesMadeBy(color)
    for i in 0..<len(level):
        tree.body.add(minimax(level[i], inverse, depth-1))
        tree.body[i].move = moves[i]
        if depth == 1:
            tree.body[i].value = level[i].calculateScoreForColor(color)
        else:
            try:
                tree.body[i].value = min(tree.body[i].body).value
            except IndexError:
                tree.body[i].value = 1000

    return tree
