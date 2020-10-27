import reversi, controller

type Runner = ref object
    playerOne: Controller
    playerTwo: Controller
    currentPlayer: Controller
    currentColor: char

proc newRunner*(playerOne: Controller, playerTwo: Controller): Runner =
    return Runner(playerOne: playerOne, 
                  playerTwo: playerTwo, 
                  currentPlayer: playerOne,
                  currentColor: 'b')


proc processPlayer(self: Runner, game: Reversi, getPlayerInput: Controller, color: char) =
    let inp = getPlayerInput(game, color)
    if not (inp == "pass"):
        let move = toCellIndex(inp)
        game.makeTurn(move, color)

proc switchPlayer(self: Runner) =
    if self.currentPlayer == self.playerOne:
        self.currentPlayer = self.playerTwo
        self.currentColor = 'w'
    else:
        self.currentPlayer = self.playerOne
        self.currentColor = 'b'

proc process*(self: Runner, game: Reversi) =
    self.processPlayer(game, self.currentPlayer, self.currentColor)
    self.switchPlayer()
