//
//  Solution.swift
//  Day 16
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Valve: Hashable {
    let id: String
    let flowRate: Int
    let connectedValveIds: [String]

    init(line: String) {
        let parts = line.components(separatedBy: "; ")
        var words = parts[0].components(separatedBy: " ")
        let id = words[1]
        let flowRate = Int(words.last!.dropFirst(5))!
        words = parts[1].components(separatedBy: " ")
        var valveIds = [words.removeLast()]
        while words.last!.hasSuffix(",") {
            let id = words.removeLast().dropLast()
            valveIds.insert(String(id), at: 0)

        }

        self.id = id
        self.flowRate = flowRate
        self.connectedValveIds = valveIds
    }
}

struct Pipes {
    let valves: [String: Valve]
    let valvesWithPositiveFlows: [Valve]
    let distance: [[Valve]: Int]

    init(valves: [Valve]) {
        let allValves = valves.reduce(into: [:]) { $0[$1.id] = $1 }
        let valvesWithPositiveFlows = valves.filter { $0.flowRate > 0 }
        let initial = valvesWithPositiveFlows.reduce(into: [[Valve]: Int]()) { result, end in
            let start = allValves["AA"]!
            result[[start, end]] = findShortestPath(from: start.id) { $0 == end.id ? nil : allValves[$0]!.connectedValveIds }.count
        }
        self.distance = valvesWithPositiveFlows.reduce(into: initial) { result, start in
            result = valvesWithPositiveFlows.reduce(into: result) { result, end in
                guard start != end else { return }
                result[[start, end]] = findShortestPath(from: start.id) { $0 == end.id ? nil : allValves[$0]!.connectedValveIds }.count
            }
        }
        self.valves = allValves
        self.valvesWithPositiveFlows = valvesWithPositiveFlows
    }

    func moveAndOpen(from start: Valve, to end: Valve, time: inout Int) -> Int {
        let cost = distance[[start, end]]!
        time = max(0, time - cost)
        return time * end.flowRate
    }
}

func findShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> [Node] {
    typealias Path = [Node]
    var visited: [Node: Path] = [:]
    var queue: [(node: Node, path: Path)] = [(start, [])]

    while queue.isEmpty == false {
        var (node, path) = queue.removeFirst()
        path.append(node)
        guard let nextNodes = getNextNodes(node) else {
            return path
        }
        for nextNode in nextNodes {
            if let previousPath = visited[nextNode], previousPath.count <= path.count {
                continue
            }
            if queue.contains(where: { $0.node == nextNode } ) {
                continue
            }
            queue.append((nextNode, path))
        }
        visited[node] = path
    }

    // No possible path exists
    fatalError()
}

func findAllPaths<Node>(from start: Node, using getNextNodes: (Node) -> [Node]) -> [[Node]] {
    var paths: [[Node]] = []
    var queue: [(node: Node, path: [Node])] = [(start, [])]
    while queue.isEmpty == false {
        let (node, path) = queue.removeFirst()
        let nextNodes = getNextNodes(node)
        guard nextNodes.isEmpty == false else {
            paths.append(path)
            continue
        }
        for next in nextNodes {
            queue.append((next, path + [next]))
        }
    }
    return paths
}

struct State: Hashable {
    let time: Int
    let location: Valve
    let remaining: Set<Valve>
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let pipes = Pipes(valves: source.data.map(Valve.init(line:)))

        let start = State(time: 30, location: pipes.valves["AA"]!, remaining: Set(pipes.valvesWithPositiveFlows))
        let paths = findAllPaths(from: start) { state in
            state.remaining.compactMap { next in
                let distance = pipes.distance[[state.location, next]]!
                guard distance < state.time else { return nil }
                var remaining = state.remaining
                remaining.remove(next)
                return State(time: state.time - distance, location: next, remaining: remaining)
            }
        }

        let totals = paths.map { path in
            var time = 30
            var total = 0
            var start = pipes.valves["AA"]!
            for state in path {
                total += pipes.moveAndOpen(from: start, to: state.location, time: &time)
                start = state.location
            }
            return total
        }
        let max = totals.max()!

        print("Part 1 (\(source)): \(max)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data

        print("Part 2 (\(source)):")
    }
}
