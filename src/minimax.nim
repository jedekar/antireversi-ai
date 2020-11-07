import sugar, sequtils
import reversi

const Infinity = 1000

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

proc minimax*(game: Reversi, color: char, depth: int): MinimaxTree =
    proc min(s: seq[MinimaxTree]): MinimaxTree =
        result = s[minIndex(map(s, (a) => a.value))]

    let inverse = inverseof(color)
    let tree = newMinimaxTree()
    let moves = game.getAvailableMovesFor(color)
    if depth == 0 or len(moves) == 0:
        tree.value = game.calculateScoreForColor(color)
        return tree

    let level = game.copyGameWithMovesMadeBy(color)

    for i in 0..<len(level):
        tree.body.add(minimax(level[i], inverse, depth-1))
        tree.body[i].move = moves[i]
    
    let negamax = if (depth mod 2) == 0: -1 else: 1
    try:
        tree.value = negamax * min(tree.body).value
    except IndexError:
        tree.value = negamax * Infinity

    return tree

proc getMoveWithMaxValue*(trees: seq[MinimaxTree]): CellIndex = 
    var value = Infinity
    for i in 0..<len(trees):
        if value > trees[i].value:
            value = trees[i].value
            result = trees[i].move
