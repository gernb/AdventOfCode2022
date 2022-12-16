//
//  main.swift
//  Day 15
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var upLeft: Self { .init(x: x - 1, y: y - 1) }
    var upRight: Self { .init(x: x + 1, y: y - 1) }
    var downLeft: Self { .init(x: x - 1, y: y + 1) }
    var downRight: Self { .init(x: x + 1, y: y + 1) }

    func distance(to other: Self) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

struct Sensor {
    let center: Position
    let beacon: Position
    let radius: Int

    var xRange: ClosedRange<Int> { (center.x - radius) ... (center.x + radius) }

    func contains(_ position: Position) -> Bool {
        return position.distance(to: center) <= radius
    }
}

func parseInput(_ lines: [String]) -> [Sensor] {
    return lines.map { line in
        let parts = line.components(separatedBy: " ")
        var value = String(parts[2].dropFirst(2).dropLast())
        var x = Int(value)!
        value = String(parts[3].dropFirst(2).dropLast())
        var y = Int(value)!
        let sensor = Position(x: x, y: y)
        value = String(parts[8].dropFirst(2).dropLast())
        x = Int(value)!
        value = String(parts[9].dropFirst(2))
        y = Int(value)!
        let beacon = Position(x: x, y: y)
        return Sensor(center: sensor, beacon: beacon, radius: sensor.distance(to: beacon))
    }
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let sensors = parseInput(source.data)
        let beacons = Set(sensors.map(\.beacon))
        let xValues = sensors.flatMap { [$0.xRange.lowerBound, $0.xRange.upperBound] }.sorted()
        let xRange = (xValues.first! ... xValues.last!)

        var count = 0
        for x in xRange {
            let position = Position(x: x, y: source.row)
            guard beacons.contains(position) == false else {
                continue
            }
            for sensor in sensors {
                if sensor.contains(position) {
                    count += 1
                    break
                }
            }
        }

        print("Part 1 (\(source)): \(count)")
    }
}

print("Day 15:")
InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

struct Circumference: Sequence, IteratorProtocol {
    let center: Position
    let radius: Int

    private var position: Position
    private var keypath: KeyPath<Position, Position>

    init(center: Position, radius: Int) {
        self.center = center
        self.radius = radius

        self.position = Position(x: center.x, y: center.y - radius)
        self.keypath = \Position.downRight
    }

    mutating func next() -> Position? {
        if position.y == center.y && keypath == \Position.downRight {
            keypath = \Position.downLeft
        } else if position.x == center.x && keypath == \Position.downLeft {
            keypath = \Position.upLeft
        } else if position.y == center.y && keypath == \Position.upLeft {
            keypath = \Position.upRight
        } else if position.x == center.x && keypath == \Position.upRight {
            return nil
        }

        defer { position = position[keyPath: keypath] }
        return position
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        let sensors = parseInput(source.data)
        var beacon: Position?
        for sensor in sensors {
            for position in Circumference(center: sensor.center, radius: sensor.radius + 1) {
                guard position.x >= 0 && position.x <= source.max &&
                        position.y >= 0 && position.y <= source.max else {
                    continue
                }
                if sensors.contains(where: { $0.contains(position) }) == false {
                    beacon = position
                    break
                }
            }
            if beacon != nil { break }
        }
        let tuningFrequency = beacon!.x * 4_000_000 + beacon!.y

        print("Part 2 (\(source)): \(tuningFrequency)")
    }
}

print("")
InputData.allCases.forEach(Part2.run)
