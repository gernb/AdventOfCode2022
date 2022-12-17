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

struct Vault {
    let emptyRow = Array(repeating: " ", count: 7)
    var jets: Jets
    var rocks = Rocks()
    var vault: [Int: [String]] = [:]

    var height: Int {
        vault.keys.max()! + 1
    }

    init(_ jets: Array<Character>) {
        self.jets = .init(jets)
    }

    func draw() -> [String] {
        let top = vault.keys.max() ?? 0
        return (0 ... top).reversed().map { row in
            vault[row, default: emptyRow].joined()
        }
    }

    mutating func dropRock() {
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
//        let height = vault.keys.max()! + 1
//        assert((0 ..< height).allSatisfy { vault[$0] != nil })
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        var vault = Vault(source.data)
        for _ in 1 ... 2022 {
            vault.dropRock()
        }

        print("Part 1 (\(source)): \(vault.height)")
    }
}

// MARK: - Part 2

extension ArraySlice {
    func split() -> (ArraySlice<Element>, ArraySlice<Element>) {
        (self[startIndex ..< startIndex + count / 2], self[startIndex + count / 2 ..< endIndex])
    }
}

extension Vault {
    var stack: [[String]] {
        vault.sorted { $0.key < $1.key }.map(\.value)
    }

    func findPattern() -> (preamble: [[String]], pattern: [[String]])? {
        let stack = self.stack
        let count = stack.count
        let preambleMax = max(0, count - 100)
        for preambleCount in 0 ..< preambleMax {
            let preamble = stack.prefix(preambleCount)
            let halves = stack.dropFirst(preambleCount).split()
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
        var vault = Vault(source.data)
        var states: [ [[String]] ] = []
        var preambleState: [[String]]!
        var patternState: [[String]]!
        var preambleRockCount = 0
        var patternRockCount = 0
        var rockCount = 0

        states.append(vault.stack)
        while true {
            vault.dropRock()
            states.append(vault.stack)
            rockCount += 1
            vault.dropRock()
            states.append(vault.stack)
            rockCount += 1
            if let (preamble, pattern) = vault.findPattern() {
                if let index = states.firstIndex(of: preamble + pattern) {
                    preambleState = preamble
                    patternState = pattern
                    preambleRockCount = index
                    patternRockCount = rockCount - index
                    break
                }
            }
        }

        let repeatCount = (Self.maxRocks - preambleRockCount) / patternRockCount
        let remainder = (Self.maxRocks - preambleRockCount) % patternRockCount
        let height = states[preambleRockCount + remainder].count - preambleState.count
        let result = preambleState.count + repeatCount * patternState.count + height

        print("Part 2 (\(source)): \(result)")
    }
}
