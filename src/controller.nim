import strformat, sugar, random
import reversi, minimax

const Letters = "ABCDEFGH"
const Numbers = "12345678"

const Pass = "pass"

proc toCellIndex*(inp: string): CellIndex =
    let y = Numbers.find(inp[1])
    let x = Letters.find(inp[0])
    return (y, x)

proc toOutput*(cellIndex: CellIndex): string =
    result = fmt"{Letters[cellIndex.x]}{Numbers[cellIndex.y]}"


proc getRandomInput(game: Reversi, color: char): string =
    let moves = game.getAvailableMovesFor(color) 
    if moves.len() > 0:
        randomize()
        let move = toOutput(sample(moves))
        return move
    return Pass

proc getConsoleInput(game: Reversi, color: char): string =
    return readLine(stdin)

proc getAiInput(game: Reversi, color: char): string =
    let node = alphabeta(game, color, 6, -Infinity, Infinity)
    if node.move == InvalidCell:
        echo Pass
        return Pass

    result = toOutput(node.move)
    echo result


type Controller* = ref object 
    color*: char
    getInput*: (Reversi) -> string

proc newRandomController*(color: char): Controller =
    return Controller(color: color,
                      getInput: (game: Reversi) => getRandomInput(game, color))

proc newConsoleController*(color: char): Controller =
    return Controller(color: color,
                      getInput: (game: Reversi) => getConsoleInput(game, color))

proc newAiController*(color: char): Controller = 
    return Controller(color: color, 
                      getInput: (game: Reversi) => getAiInput(game, color))


proc prepare*(): (Controller, Controller, CellIndex) =
    var playerOne, playerTwo: Controller
    let blackHole = toCellIndex(readLine(stdin))
    let aiColor = readLine(stdin)
    if aiColor == "black":
        playerOne = newAiController(Black)
        playerTwo = newConsoleController(White)
    else:
        playerOne = newConsoleController(Black)
        playerTwo = newAiController(White)

    return (playerOne, playerTwo, blackHole)
