import reversi

const Infinity* = 1000

proc copyGameWithMovesMadeBy(game: Reversi, color: char): seq[Reversi] = 
    let moves = game.getAvailableMovesFor(color)
    for i in 0..<len(moves):
        result.add(deepCopy(game))
        result[i].makeTurn(moves[i], color)

type MinimaxNode = ref object
    value*: int
    move*: CellIndex

proc newMinimaxNode(): MinimaxNode =
    return MinimaxNode(value: -1, move: InvalidCell)

proc alphabeta*(
    game: Reversi, color: char, depth: int, alpha: int, beta: int): MinimaxNode =
    var alpha = alpha
    let inverse = inverseof(color)
    let node = newMinimaxNode()
    let moves = game.getAvailableMovesFor(color)
    if depth == 0 or len(moves) == 0:
        node.value = game.calculateScoreForColor(inverse)
        return node

    let level = game.copyGameWithMovesMadeBy(color)

    node.value = -Infinity
    for i in 0..<len(level):
        var prev = node.value
        node.value = max(node.value,
                         -alphabeta(level[i], inverse, depth-1, -beta, -alpha).value)
        if prev != node.value: node.move = moves[i]
        alpha = max(alpha, node.value)
        if alpha >= beta:
            break
    
    return node
