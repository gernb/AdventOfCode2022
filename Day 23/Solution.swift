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

    var area: Int {
        xRange.count * yRange.count
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

typealias ProposedDirection = (proposal: KeyPath<Position, [Position]>, move: KeyPath<Position, Position>)
let initialProposedDirections: [ProposedDirection] = [
    (\.up, \.north),
    (\.down, \.south),
    (\.left, \.west),
    (\.right, \.east),
]

// MARK: - Part 1

enum Part1 {
    static func round(elves: inout Set<Position>, proposedDirections: inout [ProposedDirection]) {
        func draw() {
            BoundingBox(containing: elves).draw { x, y in
                elves.contains(.init(x: x, y: y)) ? "#" : "."
            }
        }
//        draw()
        var proposals: [Position: [Position]] = [:]
        for elf in elves {
            if elf.adjacent.allSatisfy({ elves.contains($0) == false }) {
                continue
            }
            for direction in proposedDirections {
                if elf[keyPath: direction.proposal].allSatisfy({ elves.contains($0) == false }) {
                    proposals[elf[keyPath: direction.move], default: []] += [elf]
                    break
                }
            }
        }
        for proposal in proposals where proposal.value.count == 1 {
            elves.insert(proposal.key)
            elves.remove(proposal.value[0])
        }
        proposedDirections.rotateLeft()
    }

    static func run(_ source: InputData) {
        var elves = loadScan(source.lines)
        var proposedDirections = initialProposedDirections

        for _ in 1 ... 10 {
            round(elves: &elves, proposedDirections: &proposedDirections)
        }

        let boundingBox = BoundingBox(containing: elves)
        let emptySpaces = boundingBox.area - elves.count

        print("Part 1 (\(source)): \(emptySpaces)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        var elves = loadScan(source.lines)
        var proposedDirections = initialProposedDirections
        var count = 0
        var previousScan = elves

        repeat {
            count += 1
            previousScan = elves
            Part1.round(elves: &elves, proposedDirections: &proposedDirections)
        } while elves != previousScan

        print("Part 2 (\(source)): \(count)")
    }
}
