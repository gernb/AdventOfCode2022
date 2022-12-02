//
//  main.swift
//  Day 02
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

// MARK: - Part 1

print("Day 02:")

enum Move {
    case rock, paper, scissors

    var shapeScore: Int {
        switch self {
        case .rock: return 1
        case .paper: return 2
        case .scissors: return 3
        }
    }

    static func move(for letter: String) -> Move {
        switch letter {
        case "A", "X": return .rock
        case "B", "Y": return .paper
        case "C", "Z": return .scissors
        default:
            fatalError()
        }
    }
}

struct Round {
    let player: Move
    let opponent: Move

    var outcomeScore: Int {
        switch (player, opponent) {
        case (.rock, .paper): return 0 // lost
        case (.paper, .rock): return 6 // won
        case (.rock, .scissors): return 6 // won
        case (.scissors, .rock): return 0 // lost
        case (.paper, .scissors): return 0 // lost
        case (.scissors, .paper): return 6 // won
        default: // both are same
            return 3 // draw
        }
    }

    var score: Int {
        player.shapeScore + outcomeScore
    }

    init(line: String) {
        let parts = line.components(separatedBy: " ")
        self.opponent = Move.move(for: parts[0])
        self.player = Move.move(for: parts[1])
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let input = source.data
        let rounds = input.map(Round.init(line:))
        let total = rounds.map(\.score).reduce(0, +)

        print("Part 1 (\(source)): \(total)")
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
