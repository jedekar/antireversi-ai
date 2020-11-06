import strformat, tables, sugar, random, sequtils
import reversi

const Letters = "ABCDEFGH"
const Numbers = "12345678"

proc toCellIndex*(inp: string): CellIndex =
    let y = Numbers.find(inp[1])
    let x = Letters.find(inp[0])
    return (y, x)


proc toOutput*(cellIndex: CellIndex): string =
    result = fmt"{Letters[cellIndex.x]}{Numbers[cellIndex.y]}"


type Controller* = ref object 
    color*: char
    getInput*: (Reversi, char) -> string

proc newController*(color: char, getInput: (Reversi, char) -> string): Controller =
    return Controller(color: color, getInput: getInput)

proc getRandomInput(game: Reversi, color: char): string =
    let coverage = game.getCoverage(color)
    if coverage.len() > 0:
        randomize()
        let move = toOutput(sample(toSeq(coverage.keys)))
        echo move
        return move
    return "pass"

proc getOpponentInput(game: Reversi, color: char): string =
    return readLine(stdin)

proc copyGameWithMovesMadeBy(game: Reversi, color: char): seq[Reversi] = 
    let moves = game.getAvailableMovesForColor(color)
    for i in 0..<len(moves):
        result.add(deepCopy(game))
        result[i].makeTurn(moves[i], color)

type 
    MinimaxTreeKind = enum Marked, Other
    MinimaxTree = ref object
        value*: int
        body*: seq[MinimaxTree]
        case kind: MinimaxTreeKind
            of Marked: move*: CellIndex
            of Other: discard

proc newMinimaxTree(kind: MinimaxTreeKind): MinimaxTree =
    case kind:
        of Marked: 
            return MinimaxTree(value: -1, body: @[], kind: kind, move: InvalidCell)
        of Other: 
            return MinimaxTree(value: -1, body: @[], kind: kind)

proc getMoveWithMaxValue(trees: seq[MinimaxTree]): CellIndex = 
    var value = 0
    for i in 0..<len(trees):
        if value < trees[i].value:
            value = trees[i].value
            result = trees[i].move

proc minimax(game: Reversi, color: char, depth: int): MinimaxTree =
    proc min(s: seq[MinimaxTree]): MinimaxTree =
        result = s[minIndex(map(s, (a) => a.value))]
    let inverse = inverseof(color)
    let tree = newMinimaxTree(Marked)
    let moves = game.getAvailableMovesForColor(color)
    if len(moves) == 0 or depth == 0:
        return tree

    let level = game.copyGameWithMovesMadeBy(color)
    for i in 0..<len(level):
        tree.body.add(minimax(level[i], inverse, depth-1))
        tree.body[i].move = moves[i]
        if depth == 1:
            tree.body[i].value = level[i].calculateScoreForColor(color)
        else:
            tree.body[i].value = min(tree.body[i].body).value

    return tree

proc getAiInput(game: Reversi, color: char): string =
    let tree = minimax(game, color, 2)
    if len(tree.body) == 0:
        return "pass"

    result = toOutput(getMoveWithMaxValue(tree.body))

proc newAiController*(color: char): Controller = 
    return Controller(color: color, getInput: getAiInput)

proc prepare*(): (Controller, Controller, CellIndex) =
    var playerOne, playerTwo: Controller
    let blackHole = toCellIndex(readLine(stdin))
    let aiColor = readLine(stdin)
    if aiColor == "black":
        playerOne = newController(Black, getRandomInput)
        playerTwo = newController(White, getOpponentInput)
    else:
        playerOne = newController(Black, getOpponentInput)
        playerTwo = newController(White, getRandomInput)

    return (playerOne, playerTwo, blackHole)
