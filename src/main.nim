import reversi, controller, runner

let gameInfo = prepare()
let game = newReversi(game_info[2])
let gameRunner = newRunner(game_info[0], game_info[1])
while not game.isFinished():
    gameRunner.process(game)
