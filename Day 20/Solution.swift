//
//  Solution.swift
//  Day 20
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

// MARK: - Part 1

/* UNUSED
final class Node {
    let id: Int
    let value: Int
    weak var previous: Node!
    weak var next: Node!

    init(id: Int, value: Int, previous: Node? = nil, next: Node? = nil) {
        self.id = id
        self.value = value
        self.previous = previous
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    var description: String { "id: \(id), value: \(value)" }
}

struct List {
    var count: Int
    let nodes: [Node]
    var current: Node

    init(_ numbers: [Int]) {
        self.count = numbers.count
        self.nodes = numbers.enumerated().map { Node(id: $0.offset, value: $0.element) }
        self.current = nodes[0]
        for (index, node) in nodes.enumerated() {
            if index < count - 1 {
                node.next = nodes[index + 1]
            } else {
                node.next = nodes.first
            }
            if index == 0 {
                node.previous = nodes.last
            } else {
                node.previous = nodes[index - 1]
            }
        }
    }

    mutating func move(toId: Int) {
        while current.id != toId {
            current = current.next
        }
    }

    mutating func move(toValue: Int) {
        while current.value != toValue {
            current = current.next
        }
    }

    func moveAmount(for value: Int, len: Int) -> Int {
        abs(value) % len
    }

    mutating func move(value: Int) {
        let direction = value < 0 ? \Node.previous : \Node.next
        let value = moveAmount(for: value, len: count)
        guard value > 0 else {
            return
        }
        for _ in 1 ... value {
            current = current[keyPath: direction]!
        }
    }

    mutating func remove(id: Int) -> Node {
        move(toId: id)
        let next = current.next!
        let previous = current.previous!
        next.previous = previous
        previous.next = next
        count -= 1
        return current
    }

    mutating func insert(_ node: Node) {
        node.next = current.next
        node.previous = current
        current.next = node
        node.next.previous = node
        current = node
        count += 1
    }

    mutating func mix() {
        for (id, node) in nodes.enumerated() {
            let value = node.value < 0 ? node.value - 1 : node.value
            guard moveAmount(for: value, len: count - 1) > 0 else {
                continue
            }
            let temp = remove(id: id)
            move(value: value)
            insert(temp)
        }
    }
}

extension List {
    func dump() -> [Int] {
        var numbers: [Int] = []
        var node = current.next!
        let startId = node.id
        repeat {
            numbers.append(node.value)
            node = node.next
        } while node.id != startId
        return numbers
    }
}
*/

enum Part1 {
    static func mix(_ numbers: [Int]) -> [Int] {
        let encryptedFile = numbers.enumerated().map { (value: $0.element, id: $0.offset) }
        let count = encryptedFile.count - 1
        var decryptedFile = encryptedFile
        for number in encryptedFile {
            guard number.value != 0 else { continue }
            let index = decryptedFile.firstIndex(where: { $0.id == number.id })!
            decryptedFile.remove(at: index)
            var newIndex = (index + number.value) % count
            if newIndex < 0 {
                newIndex = count + newIndex
            }
            if newIndex == 0 {
                newIndex = count
            }
            decryptedFile.insert(number, at: newIndex)
        }
        return decryptedFile.map(\.value)
    }

    static func run(_ source: InputData) {
        let decryptedFile = mix(source.numbers)
        let indexOfZero = decryptedFile.firstIndex(of: 0)!
        let coords = [1000, 2000, 3000].map {
            decryptedFile[(indexOfZero + $0) % decryptedFile.count]
        }
        print(coords)

        print("Part 1 (\(source)): \(coords.reduce(0, +))")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let encryptedFile = source.numbers

        print("Part 2 (\(source)):")
    }
}
