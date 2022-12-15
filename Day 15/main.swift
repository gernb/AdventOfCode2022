//
//  main.swift
//  Day 15
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

//    static let origin: Self = .init(x: 0, y: 0)

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var upLeft: Self { .init(x: x - 1, y: y - 1) }
    var upRight: Self { .init(x: x + 1, y: y - 1) }
    var downLeft: Self { .init(x: x - 1, y: y + 1) }
    var downRight: Self { .init(x: x + 1, y: y + 1) }

    var adjacent: [Self] { [upLeft, up, upRight, left, right, downLeft, down, downRight] }
//    var neighbours: [Self] { [up, left, right, down] }

    func distance(to other: Self) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

extension Collection where Element: Comparable {
    func range() -> ClosedRange<Element> {
        precondition(count > 0)
        let sorted = self.sorted()
        return sorted.first! ... sorted.last!
    }
}

extension Dictionary where Key == Position {
    var xRange: ClosedRange<Int> { keys.map { $0.x }.range() }
    var yRange: ClosedRange<Int> { keys.map { $0.y }.range() }

    func draw(default: Value, overwrite: Bool = true) {
        let xRange = self.xRange
        let yRange = self.yRange
        if overwrite {
            print("\u{001b}[H") // send the cursor home
        }
        for y in yRange {
            for x in xRange {
                let pixel = self[Key(x: x, y: y), default: `default`]
                print(pixel, terminator: "")
            }
            print("")
        }
    }
}

enum Item: String, CustomStringConvertible {
    case sensor = "S"
    case beacon = "B"
    case empty = " "

    var description: String { self.rawValue }
}

struct Pair {
    let sensor: Position
    let beacon: Position

    var distance: Int { sensor.distance(to: beacon) }
    var xRange: ClosedRange<Int> { (sensor.x - distance - 1) ... (sensor.x + distance + 1) }
    var yRange: ClosedRange<Int> { (sensor.y - distance - 1) ... (sensor.y + distance + 1) }

    func insideRadius(_ position: Position) -> Bool {
        return position.distance(to: sensor) <= distance
    }
}

func parseInput(_ lines: [String]) -> (pairs: [Pair], map: [Position: Item]) {
    let pairs = lines.map { line in
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
        return Pair(sensor: sensor, beacon: beacon)
    }
    var map: [Position: Item] = [:]
    pairs.forEach { pair in
        map[pair.sensor] = .sensor
        map[pair.beacon] = .beacon
    }
    return (pairs, map)
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let (pairs, map) = parseInput(source.data)
        let contributingPairs = pairs.filter { $0.yRange.contains(source.row) }
        let xValues = contributingPairs.flatMap { [$0.xRange.lowerBound, $0.xRange.upperBound] }.sorted()
        let xRange = (xValues.first! ... xValues.last!)

        var count = 0
        for x in xRange {
            let position = Position(x: x, y: source.row)
            guard map.keys.contains(position) == false else {
                continue
            }
            for pair in contributingPairs {
                if pair.insideRadius(position) {
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

enum Part2 {
    static func run(_ source: InputData) {
        let (pairs, map) = parseInput(source.data)
        let keys = Set(map.keys)
        var beacon: Position?
        for pair in pairs {
            let radius = pair.distance + 1
            var position = Position(x: pair.sensor.x, y: pair.sensor.y - radius)
            var keypath = \Position.downRight
            while beacon == nil {
                if position.y == pair.sensor.y && keypath == \Position.downRight {
                    keypath = \Position.downLeft
                } else if position.x == pair.sensor.x && keypath == \Position.downLeft {
                    keypath = \Position.upLeft
                } else if position.y == pair.sensor.y && keypath == \Position.upLeft {
                    keypath = \Position.upRight
                } else if position.x == pair.sensor.x && keypath == \Position.upRight {
                    break
                }
                guard position.x >= 0 && position.x <= source.max &&
                        position.y >= 0 && position.y <= source.max else {
                    position = position[keyPath: keypath]
                    continue
                }
                guard keys.contains(position) == false else {
                    position = position[keyPath: keypath]
                    continue
                }
                var isPossibleLocation = true
                for otherPair in pairs {
                    if otherPair.insideRadius(position) {
                        isPossibleLocation = false
                        break
                    }
                }
                if isPossibleLocation {
                    beacon = position
                } else {
                    position = position[keyPath: keypath]
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
