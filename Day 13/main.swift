//
//  main.swift
//  Day 13
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum Packet {
    case number(Int)
    indirect case list([Packet])

    init(_ input: inout ArraySlice<Character>) {
        var packets = [Packet]()
        var chars = [Character]()
        while let char = input.popFirst() {
            switch char {
            case "[":
                packets.append(.init(&input))
                break
            case "]":
                if chars.isEmpty == false {
                    let value = Int(String(chars))!
                    packets.append(.number(value))
                }
                self = .list(packets)
                return
            case ",":
                if chars.isEmpty == false {
                    let value = Int(String(chars))!
                    chars = []
                    packets.append(.number(value))
                }
                break
            default:
                chars.append(char)
                break
            }
        }
        self = .list(packets)
    }
}

struct Pair {
    let lhs: Packet
    let rhs: Packet

    init(lines: ArraySlice<String>) {
        var line = Array(lines.first!)[...]
        self.lhs = .init(&line)
        line = Array(lines.last!)[...]
        self.rhs = .init(&line)
    }
}

// MARK: - Part 1

extension Packet {
    static func compare(lhs: Self, rhs: Self) -> ComparisonResult {
        switch (lhs, rhs) {
        case let (.number(left), .number(right)):
            return left < right ? .orderedAscending : left > right ? .orderedDescending : .orderedSame
        case let (.number, .list(right)):
            return compare(lhs: [lhs], rhs: right)
        case let (.list(left), .number):
            return compare(lhs: left, rhs: [rhs])
        case let (.list(left), .list(right)):
            return compare(lhs: left, rhs: right)
        }
    }

    private static func compare(lhs: [Packet], rhs: [Packet]) -> ComparisonResult {
        for (index, packet) in lhs.enumerated() {
            guard index < rhs.count else {
                return .orderedDescending
            }
            let result = compare(lhs: packet, rhs: rhs[index])
            if result == .orderedSame {
                continue
            } else {
                return result
            }
        }
        return lhs.count == rhs.count ? .orderedSame : .orderedAscending
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let pairs = source.pairs.map(Pair.init(lines:))
        let count = pairs.map { Packet.compare(lhs: $0.lhs, rhs: $0.rhs) }
            .enumerated()
            .map { index, result in
                result == .orderedAscending ? index + 1 : 0
            }
            .reduce(0, +)

        print("Part 1 (\(source)): \(count)")
    }
}

print("Day 13:")
InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

extension Packet: Equatable {}

enum Part2 {
    static func run(_ source: InputData) {
        let dividerPackets = ["[[2]]", "[[6]]"].map {
            var line = Array($0)[...]
            return Packet(&line)
        }
        let packets = source.data.compactMap { line -> Packet? in
            guard line.isEmpty == false else { return nil }
            var line = Array(line)[...]
            return Packet(&line)
        }
        let sorted = (packets + dividerPackets).sorted { lhs, rhs in
            return Packet.compare(lhs: lhs, rhs: rhs) == .orderedAscending
        }
        let start = sorted.firstIndex(of: dividerPackets[0])! + 1
        let end = sorted.firstIndex(of: dividerPackets[1])! + 1

        print("Part 2 (\(source)): \(start * end)")
    }
}

print("")
InputData.allCases.forEach(Part2.run)
