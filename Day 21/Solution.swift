//
//  Solution.swift
//  Day 21
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Operation {
    case add(String, String)
    case subtract(String, String)
    case multiply(String, String)
    case divide(String, String)
    case yell(Int)
}

typealias Jobs = [String: Operation]

// root: pppw + sjmn
func loadMonkeys(_ lines: [String]) -> Jobs {
    lines.reduce(into: Jobs()) { jobs, line in
        let parts = line.components(separatedBy: " ")
        let monkey = String(parts[0].dropLast())
        if let value = Int(parts[1]) {
            jobs[monkey] = .yell(value)
        } else {
            switch parts[2] {
            case "+": jobs[monkey] = .add(parts[1], parts[3])
            case "-": jobs[monkey] = .subtract(parts[1], parts[3])
            case "*": jobs[monkey] = .multiply(parts[1], parts[3])
            case "/": jobs[monkey] = .divide(parts[1], parts[3])
            default: fatalError()
            }
        }
    }
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let jobs = loadMonkeys(source.lines)

        func performJob(for monkey: String) -> Int {
            let job = jobs[monkey]!
            switch job {
            case .yell(let value): return value
            case .add(let lhs, let rhs): return performJob(for: lhs) + performJob(for: rhs)
            case .subtract(let lhs, let rhs): return performJob(for: lhs) - performJob(for: rhs)
            case .multiply(let lhs, let rhs): return performJob(for: lhs) * performJob(for: rhs)
            case .divide(let lhs, let rhs): return performJob(for: lhs) / performJob(for: rhs)
            }
        }

        let root = performJob(for: "root")

        print("Part 1 (\(source)): \(root)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
//        let input = source.data

        print("Part 2 (\(source)):")
    }
}
