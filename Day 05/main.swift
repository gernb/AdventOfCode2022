//
//  main.swift
//  Day 05
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

// MARK: - Part 1

typealias Crate = String
typealias Stack = Array<Crate>
typealias Stacks = Array<Stack>

extension Stacks {
    init(input: ArraySlice<String>) {
        let count = Int(input.last!.components(separatedBy: " ").last!)!
        var stacks = Self.init(repeating: [], count: count)
        for line in input.dropLast().reversed() {
            for (position, crate) in line.map(String.init).chunked(into: 4).enumerated() {
                let crateId = crate[1]
                if crateId != " " {
                    stacks[position].append(crateId)
                }
            }
        }
        self = stacks
    }

    mutating func perform(move: Move) {
        for _ in 1 ... move.count {
            let crate = self[move.from - 1].popLast()!
            self[move.to - 1].append(crate)
        }
    }
}

struct Move {
    let count: Int
    let from: Int
    let to: Int
}

extension Move {
    init(input: String) {
        let parts = input.components(separatedBy: " ")
        self.count = Int(parts[1])!
        self.from = Int(parts[3])!
        self.to = Int(parts[5])!
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

print("Day 05:")

enum Part1 {
    static func run(_ source: InputData) {
        let input = source.data
        let splitIndex = input.firstIndex(of: "")!
        var stacks = Stacks(input: input[0 ..< splitIndex])
        let moves = input.dropFirst(splitIndex + 1).map(Move.init(input:))

        moves.forEach { stacks.perform(move: $0) }
        let result = stacks.map(\.last!).joined()

        print("Part 1 (\(source)): \(result)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

extension Stacks {
    mutating func perform2(move: Move) {
        let crates = self[move.from - 1].suffix(move.count)
        self[move.from - 1] = self[move.from - 1].dropLast(move.count)
        self[move.to - 1].append(contentsOf: crates)
    }
}

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data
        let splitIndex = input.firstIndex(of: "")!
        var stacks = Stacks(input: input[0 ..< splitIndex])
        let moves = input.dropFirst(splitIndex + 1).map(Move.init(input:))

        moves.forEach { stacks.perform2(move: $0) }
        let result = stacks.map(\.last!).joined()

        print("Part 2 (\(source)): \(result)")
    }
}

InputData.allCases.forEach(Part2.run)
