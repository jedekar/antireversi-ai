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

proc getAiInput(game: Reversi, color: char): string =
    result = "pass"

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
