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

    init(player: Move, opponent: Move) {
        self.player = player
        self.opponent = opponent
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

enum Result: String {
    case lose = "X"
    case draw = "Y"
    case win = "Z"
}

extension Move {
    func move(for result: Result) -> Move {
        switch (self, result) {
        case (.rock, .lose): return .scissors
        case (.rock, .draw): return .rock
        case (.rock, .win): return .paper

        case (.paper, .lose): return .rock
        case (.paper, .draw): return .paper
        case (.paper, .win): return .scissors

        case (.scissors, .lose): return .paper
        case (.scissors, .draw): return .scissors
        case (.scissors, .win): return .rock
        }
    }
}

extension Round {
    static func part2(line: String) -> Round {
        let parts = line.components(separatedBy: " ")
        let opponent = Move.move(for: parts[0])
        let result = Result(rawValue: parts[1])!
        let player = opponent.move(for: result)
        return Round(player: player, opponent: opponent)
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data
        let rounds = input.map(Round.part2(line:))
        let total = rounds.map(\.score).reduce(0, +)

        print("Part 2 (\(source)): \(total)")
    }
}

InputData.allCases.forEach(Part2.run)
