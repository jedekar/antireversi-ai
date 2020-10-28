import reversi, controller, runner

let gameInfo = prepare()
let game = newReversi(gameInfo[2])
let gameRunner = newRunner(gameInfo[0], gameInfo[1])
while not game.isFinished():
    gameRunner.process(game)
