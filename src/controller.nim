import strformat, tables, sugar, random, sequtils
import reversi, minimax

const Letters = "ABCDEFGH"
const Numbers = "12345678"

proc toCellIndex*(inp: string): CellIndex =
    let y = Numbers.find(inp[1])
    let x = Letters.find(inp[0])
    return (y, x)

proc toOutput*(cellIndex: CellIndex): string =
    result = fmt"{Letters[cellIndex.x]}{Numbers[cellIndex.y]}"


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

proc getAiInput(game: Reversi, color: char): string =
    let tree = minimax(game, color, 2)
    if len(tree.body) == 0:
        return "pass"

    result = toOutput(getMoveWithMaxValue(tree.body))


type Controller* = ref object 
    color*: char
    getInput*: (Reversi) -> string

proc newRandomController*(color: char): Controller =
    return Controller(color: color,
                      getInput: (game: Reversi) => getRandomInput(game, color))

proc newOpponentController*(color: char): Controller =
    return Controller(color: color,
                      getInput: (game: Reversi) => getOpponentInput(game, color))

proc newAiController*(color: char): Controller = 
    return Controller(color: color, 
                      getInput: (game: Reversi) => getAiInput(game, color))


proc prepare*(): (Controller, Controller, CellIndex) =
    var playerOne, playerTwo: Controller
    let blackHole = toCellIndex(readLine(stdin))
    let aiColor = readLine(stdin)
    if aiColor == "black":
        playerOne = newAiController(Black)
        playerTwo = newRandomController(White)
    else:
        playerOne = newRandomController(Black)
        playerTwo = newAiController(White)

    return (playerOne, playerTwo, blackHole)
