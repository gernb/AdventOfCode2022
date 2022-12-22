//
//  Solution.swift
//  Day 21
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

typealias Monkey = String

enum Job {
    case yell(Double)
    case wait(Monkey, Monkey, action: (Double, Double) -> Double)
}

func loadMonkeys(_ lines: [String]) -> [Monkey: Job] {
    lines.reduce(into: [Monkey: Job]()) { jobs, line in
        let parts = line.components(separatedBy: " ")
        let monkey = String(parts[0].dropLast())
        if let value = Double(parts[1]) {
            jobs[monkey] = .yell(value)
        } else {
            switch parts[2] {
            case "+": jobs[monkey] = .wait(parts[1], parts[3], action: +)
            case "-": jobs[monkey] = .wait(parts[1], parts[3], action: -)
            case "*": jobs[monkey] = .wait(parts[1], parts[3], action: *)
            case "/": jobs[monkey] = .wait(parts[1], parts[3], action: /)
            default: fatalError()
            }
        }
    }
}

func performJob(for monkey: Monkey, with jobs: [Monkey: Job]) -> Double {
    switch jobs[monkey] {
    case .yell(let value): return value
    case .wait(let monkey1, let monkey2, let action):
        let lhs = performJob(for: monkey1, with: jobs)
        let rhs = performJob(for: monkey2, with: jobs)
        return action(lhs, rhs)
    case .none: fatalError()
    }
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let jobs = loadMonkeys(source.lines)
        let root = Int(performJob(for: "root", with: jobs))

        print("Part 1 (\(source)): \(root)")
    }
}

// MARK: - Part 2

func find(_ value: Double, in range: ClosedRange<Int>, using valueFor: (Int) -> Double) -> Int {
    var range = range
    while range.lowerBound != range.upperBound {
        let mid = range.lowerBound + range.count / 2
        for newRange in [range.lowerBound ... mid - 1, mid ... range.upperBound] {
            let lower = valueFor(newRange.lowerBound)
            if lower == value {
                return newRange.lowerBound
            }
            let upper = valueFor(newRange.upperBound)
            if upper == value {
                return newRange.upperBound
            }
            if (min(lower, upper) ... max(lower, upper)).contains(value) {
                range = newRange
                continue
            }
        }
    }
    fatalError()
}

extension Job {
    var waitingOnMonkeys: [Monkey] {
        switch self {
        case .yell: return []
        case .wait(let monkey1, let monkey2, _): return [monkey1, monkey2]
        }
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        var jobs = loadMonkeys(source.lines)

        func neededMonkeys(for monkey: Monkey) -> Set<Monkey> {
            let monkeys = jobs[monkey]!.waitingOnMonkeys
            return monkeys.reduce(Set(monkeys)) { $0.union(neededMonkeys(for: $1)) }
        }

        let rootMonkeys = jobs["root"]!.waitingOnMonkeys
        let unknown: Monkey
        let valueToFind: Double
        if neededMonkeys(for: rootMonkeys[0]).contains("humn") {
            unknown = rootMonkeys[0]
            valueToFind = performJob(for: rootMonkeys[1], with: jobs)
        } else {
            unknown = rootMonkeys[1]
            valueToFind = performJob(for: rootMonkeys[0], with: jobs)
        }

        let lower = 0
        let upper = Int.max / 100 // Avoid arithmetic overflow

        let valueToYell = find(valueToFind, in: lower ... upper) {
            jobs["humn"] = .yell(Double($0))
            return performJob(for: unknown, with: jobs)
        }

        print("Part 2 (\(source)): \(valueToYell)")
    }
}
