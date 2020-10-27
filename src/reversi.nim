import tables, sequtils

const FieldSize* = 8


type CellIndex* = tuple
    y: int
    x: int

const InvalidCell = (-1, -1)


type Direction = tuple
    y: int
    x: int


type Coverage* = Table[CellIndex, seq[CellIndex]]


type Reversi* = ref object
    field: array[FieldSize, array[FieldSize, char]]
    blackHole: CellIndex

proc newReversi*(blackHole: CellIndex): Reversi =
    let field = [[' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
                 [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
                 [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
                 [' ', ' ', ' ', 'w', 'b', ' ', ' ', ' '],
                 [' ', ' ', ' ', 'b', 'w', ' ', ' ', ' '],
                 [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
                 [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
                 [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']]
    return Reversi(field: field, blackHole: blackHole)


proc inverseof(color: char): char =
    if color == 'b':
        return 'w'
    return 'b'


proc isValidIndex(cellIndex: CellIndex): bool =
    if (0 <= cellIndex[0] and 
        cellIndex[0] < FieldSize and 
        0 <= cellIndex[1] and 
        cellIndex[1] < FieldSize):
        return true

    return false


proc getValidNeighbours(cellIndex: CellIndex): seq[CellIndex] =
    let neighbours = [(cellIndex[0] - 1, cellIndex[1]),
                      (cellIndex[0] - 1, cellIndex[1] + 1),
                      (cellIndex[0], cellIndex[1] + 1),
                      (cellIndex[0] + 1, cellIndex[1] + 1),
                      (cellIndex[0] + 1, cellIndex[1]),
                      (cellIndex[0] + 1, cellIndex[1] - 1),
                      (cellIndex[0], cellIndex[1] - 1),
                      (cellIndex[0] - 1, cellIndex[1] - 1)]
    for n in neighbours:
        if isValidIndex(n):
            result.add(n)


proc getInverseNeighbours(self: Reversi, cellIndex: CellIndex): seq[CellIndex] =
    let inverse = inverseof(self.field[cellIndex[0]][cellIndex[1]])
    let neighbours = getValidNeighbours(cellIndex)
    for n in neighbours:
        let neighbour_cell = self.field[n[0]][n[1]]
        if neighbour_cell == inverse:
            result.add(n)


proc findEmptyCell(self: Reversi, cellIndex: CellIndex, direction: Direction): CellIndex =
    let color = self.field[cellIndex[0]][cellIndex[1]]
    let inverse = inverseof(color)
    var y = cellIndex[0] + direction[0]
    var x = cellIndex[1] + direction[1]
    while true:
        if not isValidIndex((y, x)):
            return InvalidCell
        let current = self.field[y][x]
        if current == inverse:
            return InvalidCell
        if current == ' ':
            return (y, x)
        if current == color:
            y += direction[0]
            x += direction[1]
            continue


proc getDirections(cellIndex: CellIndex, points: seq[CellIndex]): seq[Direction] =
    for p in points:
        result.add((p[0] - cellIndex[0], p[1] - cellIndex[1]))


proc getAvailableMoves(self: Reversi, cellIndex: CellIndex): seq[CellIndex] =
    let n = self.getInverseNeighbours(cellIndex)
    let d = getDirections(cellIndex, n)
    for i in 0..<len(n):
        let move = self.findEmptyCell(n[i], d[i])
        if move != InvalidCell:
            result.add(move)

proc getPieces(self: Reversi, color: char): seq[CellIndex] =
    for i in 0..<FieldSize:
        for j in 0..<FieldSize:
            let current = self.field[i][j]
            if current == color:
                result.add((i, j))


proc getCoverageWithBlackHole(self: Reversi, color: char): Coverage =
    let pieces = self.getPieces(color)

    for p in pieces:
        let moves = self.getAvailableMoves(p)
        for m in moves:
            if not result.hasKey(m):
                result[m] = @[p]
            else:
                result[m].add(p)


proc getCoverage*(self: Reversi, color: char): Coverage =
    result = self.getCoverageWithBlackHole(color)
    if result.hasKey(self.black_hole):
        result.del(self.black_hole)


proc flipRow(self: Reversi, cellIndex: CellIndex, direction: Direction) =
    let color = self.field[cellIndex[0]][cellIndex[1]]
    let inverse = inverseof(color)
    var y = cellIndex[0] + direction[0]
    var x = cellIndex[1] + direction[1]
    while true:
        let current = self.field[y][x]
        if current == inverse:
            self.field[y][x] = color
            y += direction[0]
            x += direction[1]
            continue
        break


proc normalizeDirection(direction: Direction): Direction = 
    let y = direction[0] 
    let x = direction[1]
    let ly = abs(y)
    let lx = abs(x)
    if ly > lx:
        return (int(y / ly), int(x / ly))
    if x == 0:
        return (y, x)

    return (int(y / lx), int(x / lx))


proc flipPieces(self: Reversi, attacked: CellIndex, attackers: seq[CellIndex]) =
    let color = self.field[attackers[0][0]][attackers[0][1]]
    self.field[attacked[0]][attacked[1]] = color
    let directions = map(getDirections(attacked, attackers), normalizeDirection)
    for d in directions:
        self.flipRow(attacked, d)


proc isFinished*(self: Reversi): bool =
    let blackCoverage = self.getCoverage('b')
    let whiteCoverage = self.getCoverage('w')
    if len(blackCoverage) == 0 and len(whiteCoverage) == 0:
        return true
    return false


proc makeTurn*(self: Reversi, cellIndex: CellIndex, color: char) =
    let coverage = self.getCoverage(color)
    self.flipPieces(cellIndex, coverage[cellIndex])


proc calculateScore*(self: Reversi): (int, int) =
    var black = len(self.getPieces('b'))
    var white = len(self.getPieces('w'))

    return (black, white)
