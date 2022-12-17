//
//  Solution.swift
//  Day 17
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Direction: Character {
    case left = "<"
    case right = ">"
}

struct Jets: Sequence, IteratorProtocol {
    let pattern: [Direction]
    var index = 0

    init(_ input: Array<Character>) {
        self.pattern = input.map { Direction(rawValue: $0)! }
    }

    mutating func next() -> Direction? {
        defer { index = (index + 1) % pattern.count }
        return pattern[index]
    }
}

enum Rock: CaseIterable {
    case dash, plus, l, line, square

    var shape: [[String]] {
        lines.map { $0.map(String.init) }
    }

    var lines: [String] {
        switch self {
        case .dash: return   ["  #### "]
        case .plus: return   ["   #   ", "  ###  ", "   #   "]
        case .l: return      ["    #  ", "    #  ", "  ###  "]
        case .line: return   ["  #    ", "  #    ", "  #    ", "  #    "]
        case .square: return ["  ##   ", "  ##   "]
        }
    }
}

struct Rocks: Sequence, IteratorProtocol {
    let pattern = Rock.allCases
    var index = 0

    mutating func next() -> Rock? {
        defer { index = (index + 1) % pattern.count }
        return pattern[index]
    }
}

// MARK: - Part 1

func draw(_ vault: [Int: [String]]) -> [String] {
    let top = vault.keys.max() ?? 0
    return (0 ... top).reversed().map { row in
        vault[row, default: Array(repeating: " ", count: 7)].joined()
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let emptyRow = Array(repeating: " ", count: 7)
        var jets = Jets(source.data)
        var rocks = Rocks()
        var vault: [Int: [String]] = [:]
        for _ in 1 ... 2022 {
            let shape = rocks.next()!.shape
            var bottom = (vault.keys.max() ?? -1) + 4
            var top = bottom + shape.count - 1
            shape.enumerated().forEach { index, line in
                vault[top - index] = line
            }
            var canMoveDown = true
            while canMoveDown {
                switch jets.next()! {
                case .left:
                    let canMove = shape.indices.allSatisfy { index in
                        let line = vault[top - index]!
                        let leftIndex = line.firstIndex(of: "#")!
                        return leftIndex > 0 && line[leftIndex - 1] == " "
                    }
                    if canMove {
                        shape.indices.forEach { rowIndex in
                            var line = vault[top - rowIndex]!
                            for index in 1 ..< 7 {
                                guard line[index] == "#" else { continue }
                                line[index - 1] = "#"
                                line[index] = " "
                            }
                            vault[top - rowIndex] = line
                        }
                    }
                case .right:
                    let canMove = shape.indices.allSatisfy { index in
                        let line = vault[top - index]!
                        let rightIndex = line.lastIndex(of: "#")!
                        return rightIndex < 6 && line[rightIndex + 1] == " "
                    }
                    if canMove {
                        shape.indices.forEach { rowIndex in
                            var line = vault[top - rowIndex]!
                            for index in (0 ..< 6).reversed() {
                                guard line[index] == "#" else { continue }
                                line[index + 1] = "#"
                                line[index] = " "
                            }
                            vault[top - rowIndex] = line
                        }
                    }
                }
                canMoveDown = bottom > 0 && shape.indices.reversed().allSatisfy { rowIndex in
                    let bottomRow = vault[top - rowIndex]!
                    let nextRow = vault[top - rowIndex - 1, default: emptyRow]
                    return bottomRow.indices.allSatisfy { index in
                        guard bottomRow[index] == "#" else { return true }
                        return nextRow[index] == " " || nextRow[index] == "#"
                    }
                }
                if canMoveDown {
                    shape.indices.reversed().forEach { rowIndex in
                        var line = vault[top - rowIndex]!
                        var nextLine = vault[top - rowIndex - 1, default: emptyRow]
                        for index in 0 ..< 7 {
                            guard line[index] == "#" else { continue }
                            nextLine[index] = "#"
                            line[index] = " "
                        }
                        vault[top - rowIndex - 1] = nextLine
                        vault[top - rowIndex] = line == emptyRow ? nil : line
                    }
                    bottom -= 1
                    top -= 1
                } else {
                    shape.indices.forEach { rowIndex in
                        var line = vault[top - rowIndex]!
                        line = line.replacing(["#"], with: ["@"])
                        vault[top - rowIndex] = line
                    }
                }
            }
            let height = vault.keys.max()! + 1
            assert((0 ..< height).allSatisfy { vault[$0] != nil })
        }

        let height = vault.keys.max()! + 1

        print("Part 1 (\(source)): \(height)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data

        print("Part 2 (\(source)):")
    }
}
