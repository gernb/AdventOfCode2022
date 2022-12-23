//
//  Solution.swift
//  Day 23
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var north: Self { .init(x: x, y: y - 1) }
    var south: Self { .init(x: x, y: y + 1) }
    var west: Self { .init(x: x - 1, y: y) }
    var east: Self { .init(x: x + 1, y: y) }

    var adjacent: [Self] {
        [north.west, north, north.east, west, east, south.west, south, south.east]
    }
    var up: [Self] {
        [north.west, north, north.east]
    }
    var down: [Self] {
        [south.west, south, south.east]
    }
    var left: [Self] {
        [north.west, west, south.west]
    }
    var right: [Self] {
        [north.east, east, south.east]
    }
}

extension Collection {
    func range<Value: Comparable>(of property: KeyPath<Element, Value>) -> ClosedRange<Value> {
        let values = self.map { $0[keyPath: property] }.sorted()
        return values.first! ... values.last!
    }
}

struct BoundingBox {
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>

    func count(where include: (Int, Int) -> Bool) -> Int {
        yRange.reduce(0) { result, y in
            result + xRange.reduce(0) { result, x in
                result + (include(x, y) ? 1 : 0)
            }
        }
    }

    func draw(character: (Int, Int) -> String) {
        let lines = yRange.map { y in
            xRange.map { character($0, y) }.joined()
        }
        .joined(separator: "\n")
        print(lines)
    }
}

extension BoundingBox {
    init(containing positions: any Collection<Position>) {
        self.init(
            xRange: positions.range(of: \.x),
            yRange: positions.range(of: \.y)
        )
    }
}

extension Array {
    mutating func rotateLeft() {
        self = self[1...] + [self.first!]
    }
}

func loadScan(_ lines: [String]) -> Set<Position> {
    lines.enumerated().reduce(into: Set()) { scan, item in
        let y = item.offset
        scan = item.element.enumerated().reduce(into: scan) { scan, item in
            let x = item.offset
            if item.element == "#" {
                scan.insert(.init(x: x, y: y))
            }
        }
    }
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        var scan = loadScan(source.lines)
        var proposedDirection = [
            (direction: \Position.up, move: \Position.north),
            (direction: \.down, move: \.south),
            (direction: \.left, move: \.west),
            (direction: \.right, move: \.east),
        ]

        func draw() {
            BoundingBox(containing: scan).draw { x, y in
                scan.contains(.init(x: x, y: y)) ? "#" : "."
            }
        }

        for _ in 1 ... 10 {
//            draw()
            var proposals: [Position: [Position]] = [:]
            for elf in scan {
                if elf.adjacent.allSatisfy({ scan.contains($0) == false }) {
                    continue
                }
                for direction in proposedDirection {
                    if elf[keyPath: direction.direction].allSatisfy({ scan.contains($0) == false }) {
                        proposals[elf[keyPath: direction.move], default: []] += [elf]
                        break
                    }
                }
            }
            for proposal in proposals where proposal.value.count == 1 {
                scan.insert(proposal.key)
                scan.remove(proposal.value[0])
            }
            proposedDirection.rotateLeft()
        }

        let boundingBox = BoundingBox(containing: scan)
        let emptySpaces = boundingBox.count { x, y in
            scan.contains(.init(x: x, y: y)) == false
        }

        print("Part 1 (\(source)): \(emptySpaces)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        var scan = loadScan(source.lines)
        var proposedDirection = [
            (direction: \Position.up, move: \Position.north),
            (direction: \.down, move: \.south),
            (direction: \.left, move: \.west),
            (direction: \.right, move: \.east),
        ]

        var count = 0
        var previousScan = scan
        repeat {
            count += 1
            previousScan = scan
            var proposals: [Position: [Position]] = [:]
            for elf in scan {
                if elf.adjacent.allSatisfy({ scan.contains($0) == false }) {
                    continue
                }
                for direction in proposedDirection {
                    if elf[keyPath: direction.direction].allSatisfy({ scan.contains($0) == false }) {
                        proposals[elf[keyPath: direction.move], default: []] += [elf]
                        break
                    }
                }
            }
            for proposal in proposals where proposal.value.count == 1 {
                scan.insert(proposal.key)
                scan.remove(proposal.value[0])
            }
            proposedDirection.rotateLeft()
        } while scan != previousScan

        print("Part 2 (\(source)): \(count)")
    }
}
