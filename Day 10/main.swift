//
//  main.swift
//  Day 10
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Instruction {
    case noop
    case addx(Int)

    var cycles: Int {
        switch self {
        case .noop: return 1
        case .addx: return 2
        }
    }

    init(line: String) {
        let parts = line.components(separatedBy: " ")
        switch parts[0] {
        case "noop": self = .noop
        case "addx": self = .addx(.init(parts[1])!)
        default: fatalError()
        }
    }
}

// MARK: - Part 1

print("Day 10:")

enum Part1 {
    static func run(_ source: InputData) {
        let program = source.data.map(Instruction.init(line:))
        var register = 1
        var cycles = 0
        var signalStrength: [Int: Int] = [:]

        program.forEach { instruction in
            cycles += instruction.cycles
            switch instruction {
            case .noop:
                signalStrength[cycles] = cycles * register
            case .addx(let value):
                signalStrength[cycles - 1] = (cycles - 1) * register
                signalStrength[cycles] = cycles * register
                register += value
            }
        }

        let samples = [
            signalStrength[20, default: 0],
            signalStrength[60, default: 0],
            signalStrength[100, default: 0],
            signalStrength[140, default: 0],
            signalStrength[180, default: 0],
            signalStrength[220, default: 0],
        ]
        let sum = samples.reduce(0, +)

        print("Part 1 (\(source)): \(sum)")
    }
}

InputData.allCases.forEach(Part1.run)

struct Sprite {
    let center: Int

    var pixels: [Int] {
        [center - 1, center, center + 1]
    }
}

struct CRT {
    var pixels: [Bool] = .init(repeating: false, count: 40 * 6)

    mutating func setPixel(cycle: Int, sprite: Sprite) {
        let rowPosition = (cycle - 1) % 40
        pixels[cycle - 1] = sprite.pixels.contains(rowPosition)
    }

    func draw() {
        for row in 0 ..< 6 {
            for column in 0 ..< 40 {
                let index = row * 40 + column
                print(pixels[index] ? "#" : " ", terminator: "")
            }
            print("")
        }
        print("")
    }
}

// MARK: - Part 2

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let program = source.data.map(Instruction.init(line:))
        var register = 1
        var cycles = 0
        var crt = CRT()

        program.forEach { instruction in
            cycles += instruction.cycles
            switch instruction {
            case .noop:
                crt.setPixel(cycle: cycles, sprite: .init(center: register))
            case .addx(let value):
                let sprite = Sprite(center: register)
                crt.setPixel(cycle: cycles - 1, sprite: sprite)
                crt.setPixel(cycle: cycles, sprite: sprite)
                register += value
            }
        }

        print("Part 2 (\(source)):")
        crt.draw()
    }
}

InputData.allCases.forEach(Part2.run)
