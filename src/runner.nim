import reversi, controller

type Runner = ref object
    playerOne: Controller
    playerTwo: Controller
    current: Controller

proc newRunner*(playerOne: Controller, playerTwo: Controller): Runner =
    return Runner(playerOne: playerOne, 
                  playerTwo: playerTwo, 
                  current: playerOne)


proc processPlayer(self: Runner, game: Reversi, player: Controller) =
    let inp = player.getInput(game, player.color)
    if not (inp == "pass"):
        let move = toCellIndex(inp)
        game.makeTurn(move, player.color)

proc switchPlayer(self: Runner) =
    if self.current == self.playerOne:
        self.current = self.playerTwo
    else:
        self.current = self.playerOne

proc process*(self: Runner, game: Reversi) =
    self.processPlayer(game, self.current)
    self.switchPlayer()
