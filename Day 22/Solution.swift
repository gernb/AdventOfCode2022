//
//  Solution.swift
//  Day 22
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Facing {
    case left, up, right, down

    var value: Int {
        switch self {
        case .right: return 0
        case .down: return 1
        case .left: return 2
        case .up: return 3
        }
    }

    var left: Self {
        switch self {
        case .left: return .down
        case .up: return .left
        case .right: return .up
        case .down: return .right
        }
    }

    var right: Self {
        switch self {
        case .left: return .up
        case .up: return .right
        case .right: return .down
        case .down: return .left
        }
    }
}

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }
    var row: Int { y }
    var column: Int { x }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }

    subscript(_ facing: Facing) -> Self {
        switch facing {
        case .up: return up
        case .down: return down
        case .left: return left
        case .right: return right
        }
    }
}

enum Path {
    case move(Int)
    case turn(KeyPath<Facing, Facing>)
}

enum Tile: Character {
    case open = "."
    case wall = "#"
}

struct Map {
    let board: [Position: Tile]
    let path: [Path]

    init(_ source: InputData) {
        self.board = source.map
            .enumerated()
            .reduce(into: [Position: Tile]()) { board, item in
                let y = item.offset
                board = item.element.enumerated().reduce(into: board) { board, item in
                    let x = item.offset
                    let position = Position(x: x + 1, y: y + 1)
                    board[position] = Tile(rawValue: item.element)
                }
            }
        var value = 0
        self.path = source.path.flatMap { character -> [Path] in
            if let n = Int(String(character)) {
                value = value * 10 + n
                return []
            } else {
                assert(value > 0)
                let move = Path.move(value)
                value = 0
                switch character {
                case "L": return [move, .turn(\.left)]
                case "R": return [move, .turn(\.right)]
                default: fatalError()
                }
            }
        } + (value > 0 ? [.move(value)] : [])
    }

    func leftEdge(for position: Position) -> Position {
        board.keys.filter { $0.row == position.row }.min(by: { $0.column < $1.column })!
    }
    func rightEdge(for position: Position) -> Position {
        board.keys.filter { $0.row == position.row }.max(by: { $0.column < $1.column })!
    }
    func topEdge(for position: Position) -> Position {
        board.keys.filter { $0.column == position.column }.min(by: { $0.row < $1.row })!
    }
    func bottomEdge(for position: Position) -> Position {
        board.keys.filter { $0.column == position.column }.max(by: { $0.row < $1.row })!
    }

    func next(from position: Position, facing: Facing) -> Position {
        var next = position[facing]
        switch board[next] {
        case .open: return next
        case .wall: return position
        case .none:
            switch facing {
            case .right: next = leftEdge(for: position)
            case .left: next = rightEdge(for: position)
            case .down: next = topEdge(for: position)
            case .up: next = bottomEdge(for: position)
            }
        }
        return board[next]! == .open ? next : position
    }
}

// MARK: - Part 1

extension Map {
    func followPath() -> (position: Position, facing: Facing) {
        var position = board.keys.filter { $0.row == 1 }.min(by: { $0.x < $1.x  })!
        var facing = Facing.right
        for step in path {
            switch step {
            case .turn(let direction):
                facing = facing[keyPath: direction]
            case .move(let count):
                for _ in 1 ... count {
                    let newPosition = next(from: position, facing: facing)
                    if newPosition == position {
                        break
                    }
                    position = newPosition
                }
            }
        }
        return (position, facing)
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let map = Map(source)

        let finish = map.followPath()
        let result = 1000 * finish.position.row + 4 * finish.position.column + finish.facing.value

        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

extension Position {
    var adjacent: [Self] {
        [up.left, up, up.right, left, right, down.left, down, down.right]
    }
}

struct Edge: Hashable {
    var position: Position
    var facing: Facing

    var right: Self {
        .init(position: position, facing: facing.right)
    }
    var left: Self {
        .init(position: position, facing: facing.left)
    }
    var next: Self {
        .init(position: position[facing], facing: facing)
    }
}

enum Part2 {
    static func connectEdges(of map: Map) -> [Edge: Edge] {
        let convexCorners = map.board.keys.filter { position in
            position.adjacent.filter { adjacent in
                map.board[adjacent] == nil
            }
            .count == 1
        }
        var result: [Edge: Edge] = [:]

        for corner in convexCorners {
            var cw: Edge  // clockwise
            var ccw: Edge // counter clockwise

            if map.board[corner.up.left] == nil {
                cw = .init(position: corner.up, facing: .up)
                ccw = .init(position: corner.left, facing: .left)
            } else if map.board[corner.up.right] == nil {
                cw = .init(position: corner.right, facing: .right)
                ccw = .init(position: corner.up, facing: .up)
            } else if map.board[corner.down.right] == nil {
                cw = .init(position: corner.down, facing: .down)
                ccw = .init(position: corner.right, facing: .right)
            } else { // corner.down.left
                cw = .init(position: corner.left, facing: .left)
                ccw = .init(position: corner.down, facing: .down)
            }

            var shouldContinue = true
            repeat {
                result[cw.left] = ccw.left
                result[ccw.right] = cw.right
                var cwNext = cw.next
                var ccwNext = ccw.next
                switch (map.board[cwNext.position], map.board[ccwNext.position]) {
                case (.some, .some):
                    cw = cwNext
                    ccw = ccwNext
                case (.some, .none):
                    cw = cwNext
                    ccw = ccw.left
                case (.none, .some):
                    cw = cw.right
                    ccw = ccwNext
                case (.none, .none):
                    shouldContinue = false
                }
            } while shouldContinue
        }

        return result
    }

    static func getNext(from position: Position, facing: Facing, map: Map, edges: [Edge: Edge]) -> (position: Position, facing: Facing) {
        let next = position[facing]
        switch map.board[next] {
        case .open: return (next, facing)
        case .wall: return (position, facing)
        case .none:
            let edge = Edge(position: position, facing: facing)
            let connectedTo = edges[edge]!
            switch map.board[connectedTo.position] {
            case .open: return (connectedTo.position, connectedTo.facing)
            case .wall: return (position, facing)
            case .none: fatalError()
            }
        }
    }

    static func run(_ source: InputData) {
        let map = Map(source)
        let edges = connectEdges(of: map)

        var position = map.leftEdge(for: .init(x: 1, y: 1))
        var facing = Facing.right
        for step in map.path {
            switch step {
            case .turn(let direction):
                facing = facing[keyPath: direction]
            case .move(let count):
                for _ in 1 ... count {
                    let next = getNext(from: position, facing: facing, map: map, edges: edges)
                    if next.position == position {
                        break
                    }
                    position = next.position
                    facing = next.facing
                }
            }
        }

        let result = 1000 * position.row + 4 * position.column + facing.value

        print("Part 2 (\(source)): \(result)")
    }
}
