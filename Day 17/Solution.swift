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

struct Chamber {
    let emptyRow = Array(repeating: " ", count: 7)
    var jets: Jets
    var rocks = Rocks()
    var tower: [Int: [String]] = [:]

    var height: Int {
        (tower.keys.max() ?? -1) + 1
    }

    init(_ jets: Array<Character>) {
        self.jets = .init(jets)
    }

    func draw() -> [String] {
        (0 ..< height).reversed().map { row in
            tower[row, default: emptyRow].joined()
        }
    }

    mutating func dropRock() {
        let shape = rocks.next()!.shape
        var top = (height + 3) + (shape.count - 1)
        shape.enumerated().forEach { index, line in
            tower[top - index] = line
        }
        var canMoveDown = true
        while canMoveDown {
            switch jets.next()! {
            case .left:
                let canMove = shape.indices.allSatisfy { index in
                    let line = tower[top - index]!
                    let leftIndex = line.firstIndex(of: "#")!
                    return leftIndex > 0 && line[leftIndex - 1] == " "
                }
                if canMove {
                    shape.indices.forEach { rowIndex in
                        var line = tower[top - rowIndex]!
                        for index in 1 ..< 7 {
                            guard line[index] == "#" else { continue }
                            line[index - 1] = "#"
                            line[index] = " "
                        }
                        tower[top - rowIndex] = line
                    }
                }
            case .right:
                let canMove = shape.indices.allSatisfy { index in
                    let line = tower[top - index]!
                    let rightIndex = line.lastIndex(of: "#")!
                    return rightIndex < 6 && line[rightIndex + 1] == " "
                }
                if canMove {
                    shape.indices.forEach { rowIndex in
                        var line = tower[top - rowIndex]!
                        for index in (0 ..< 6).reversed() {
                            guard line[index] == "#" else { continue }
                            line[index + 1] = "#"
                            line[index] = " "
                        }
                        tower[top - rowIndex] = line
                    }
                }
            }
            canMoveDown = (top - shape.count) >= 0 && shape.indices.reversed().allSatisfy { rowIndex in
                let bottomRow = tower[top - rowIndex]!
                let nextRow = tower[top - rowIndex - 1, default: emptyRow]
                return bottomRow.indices.allSatisfy { index in
                    guard bottomRow[index] == "#" else { return true }
                    return nextRow[index] == " " || nextRow[index] == "#"
                }
            }
            if canMoveDown {
                shape.indices.reversed().forEach { rowIndex in
                    var line = tower[top - rowIndex]!
                    var nextLine = tower[top - rowIndex - 1, default: emptyRow]
                    for index in 0 ..< 7 {
                        guard line[index] == "#" else { continue }
                        nextLine[index] = "#"
                        line[index] = " "
                    }
                    tower[top - rowIndex - 1] = nextLine
                    tower[top - rowIndex] = line == emptyRow ? nil : line
                }
                top -= 1
            } else {
                shape.indices.forEach { rowIndex in
                    var line = tower[top - rowIndex]!
                    line = line.replacing(["#"], with: ["@"])
                    tower[top - rowIndex] = line
                }
            }
        }
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        var chamber = Chamber(source.data)
        for _ in 1 ... 2022 {
            chamber.dropRock()
        }

        print("Part 1 (\(source)): \(chamber.height)")
    }
}

// MARK: - Part 2

extension ArraySlice {
    func split() -> (ArraySlice<Element>, ArraySlice<Element>) {
        (self[startIndex ..< startIndex + count / 2], self[startIndex + count / 2 ..< endIndex])
    }
}

extension Chamber {
    var rows: [String] {
        (0 ..< height).map { tower[$0]!.joined() }
    }

    func findPattern() -> (preamble: [String], pattern: [String])? {
        let rows = self.rows
        let count = rows.count
        let preambleMax = max(0, count - 100)
        for preambleCount in 0 ..< preambleMax {
            let preamble = rows.prefix(preambleCount)
            let halves = rows.dropFirst(preambleCount).split()
            if halves.0 == halves.1 {
                return (Array(preamble), Array(halves.0))
            }
        }
        return nil
    }
}

enum Part2 {
    static let maxRocks = 1_000_000_000_000

    static func run(_ source: InputData) {
        var chamber = Chamber(source.data)
        var states: [ [String] ] = [chamber.rows]
        var preambleRows: [String]!
        var patternRows: [String]!
        var preambleRockCount = 0
        var patternRockCount = 0
        var rockCount = 0

        while true {
            chamber.dropRock()
            states.append(chamber.rows)
            rockCount += 1
            if let (preamble, pattern) = chamber.findPattern() {
                if let index = states.firstIndex(of: preamble) {
                    preambleRows = preamble
                    patternRows = pattern
                    preambleRockCount = index
                    patternRockCount = (rockCount - preambleRockCount) / 2
                    break
                }
            }
        }

        let repeatCount = (Self.maxRocks - preambleRockCount) / patternRockCount
        let remainder = (Self.maxRocks - preambleRockCount) % patternRockCount
        let height = states[preambleRockCount + remainder].count - preambleRows.count
        let result = preambleRows.count + repeatCount * patternRows.count + height

        print("Part 2 (\(source)): \(result)")
    }
}
