import strformat, tables, sugar, random, sequtils
import reversi

const Letters = "ABCDEFGH"
const Numbers = "12345678"

proc toCellIndex*(inp: string): CellIndex =
    let y = Numbers.find(inp[1])
    let x = Letters.find(inp[0])
    return (y, x)


proc toOutput*(cellIndex: CellIndex): string =
    let y = cellIndex[0]
    let x = cellIndex[1]
    result = fmt"{Letters[x]}{Numbers[y]}"


type Controller* = ref object 
    color*: char
    getInput*: (Reversi, char) -> string

proc newController*(color: char, getInput: (Reversi, char) -> string): Controller =
    return Controller(color: color, getInput: getInput)

proc getAiInput(game: Reversi, color: char): string =
    let coverage = game.getCoverage(color)
    if coverage.len() > 0:
        randomize()
        let move = toOutput(sample(toSeq(coverage.keys)))
        echo move
        return move
    return "pass"

proc getOpponentInput(game: Reversi, color: char): string =
    return readLine(stdin)


proc prepare*(): (Controller, Controller, CellIndex) =
    var playerOne, playerTwo: Controller
    let blackHole = toCellIndex(readLine(stdin))
    let aiColor = readLine(stdin)
    if aiColor == "black":
        playerOne = newController('b', getAiInput)
        playerTwo = newController('w', getOpponentInput)
    else:
        playerOne = newController('b', getOpponentInput)
        playerTwo = newController('w', getAiInput)

    return (playerOne, playerTwo, blackHole)
