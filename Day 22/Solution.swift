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

enum Part2 {
    static func run(_ source: InputData) {
//        let input = source.data

        print("Part 2 (\(source)):")
    }
}
