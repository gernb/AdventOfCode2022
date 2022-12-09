//
//  main.swift
//  Day 09
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Direction: String {
    case U, D, L, R
}

struct Move {
    let direction: Direction
    let count: Int
}

extension Move {
    init(line: String) {
        let parts = line.components(separatedBy: " ")
        self.direction = .init(rawValue: parts[0])!
        self.count = .init(parts[1])!
    }
}

struct Position: Hashable {
    var x: Int
    var y: Int

    static let origin = Position(x: 0, y: 0)

    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var up: Self { .init(x: x, y: y + 1) }
    var down: Self { .init(x: x, y: y - 1) }

    var upLeft: Self { .init(x: x - 1, y: y + 1) }
    var upRight: Self { .init(x: x + 1, y: y + 1) }
    var downLeft: Self { .init(x: x - 1, y: y - 1) }
    var downRight: Self { .init(x: x + 1, y: y - 1) }

    var nineGrid: [Self] {
        [upLeft, up, upRight, left, self, right, downLeft, down, downRight]
    }

    mutating func move(_ direction: Direction) {
        switch direction {
        case .U: self.y += 1
        case .D: self.y -= 1
        case .L: self.x -= 1
        case .R: self.x += 1
        }
    }

    mutating func move(following head: Position) {
        guard head.nineGrid.contains(self) == false else { return }
        let xDiff = head.x - self.x
        let yDiff = head.y - self.y
        switch xDiff {
        case -2: self.x -= 1
        case -1: self.x -= 1
        case 0: break
        case 1: self.x += 1
        case 2: self.x += 1
        default: fatalError()
        }
        switch yDiff {
        case -2: self.y -= 1
        case -1: self.y -= 1
        case 0: break
        case 1: self.y += 1
        case 2: self.y += 1
        default: fatalError()
        }
    }
}

// MARK: - Part 1

print("Day 09:")

enum Part1 {
    static func run(_ source: InputData) {
        let moves = source.data.map(Move.init(line:))
        var head = Position.origin
        var tail = Position.origin
        var visited: Set<Position> = [tail]

        for move in moves {
            for _ in 1 ... move.count {
                head.move(move.direction)
                tail.move(following: head)
                visited.insert(tail)
            }
        }

        let count = visited.count
        print("Part 1 (\(source)): \(count)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data

        print("Part 2 (\(source)):")
    }
}

InputData.allCases.forEach(Part2.run)
