//
//  main.swift
//  Day 07
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Command {
    case cd(String)
    case ls([String])

    static func parse(_ lines: [String]) -> [Command] {
        var commands: [Command] = []
        var output: [String] = []
        for line in lines {
            if line.prefix(1) == "$" {
                if output.isEmpty == false {
                    commands.append(.ls(output))
                    output = []
                }
                let parts = line.components(separatedBy: " ")
                switch parts[1] {
                case "cd": commands.append(.cd(parts[2]))
                case "ls": break
                default: fatalError()
                }
            } else {
                output.append(line)
            }
        }
        if output.isEmpty == false {
            commands.append(.ls(output))
        }
        return commands
    }
}

final class Directory {
    let name: String
    var files: [(name: String, size: Int)] = []
    var directories: [Directory] = []

    var size: Int {
        files.map(\.size).reduce(0, +) + directories.map(\.size).reduce(0, +)
    }

    init(name: String) {
        self.name = name
    }

    @discardableResult
    func add(_ directory: String) -> Directory {
        guard let dir = directories.first(where: { $0.name == directory }) else {
            let dir = Directory(name: directory)
            directories.append(dir)
            return dir
        }
        return dir
    }

    func add(_ listing: [String]) {
        var files: [(name: String, size: Int)] = []
        for line in listing {
            let parts = line.components(separatedBy: " ")
            let name = parts[1]
            if let size = Int(parts[0]) {
                files.append((name, size))
            } else {
                assert(parts[0] == "dir")
                add(name)
            }
        }
        self.files = files
    }
}

extension Directory: CustomStringConvertible {
    var description: String {
        "\(name): \(files), \(directories)"
    }
}

extension Array where Element == Command {
    func execute(with root: Directory) {
        var path: [Directory] = []
        for command in self {
            switch command {
            case .cd("/"):
                path = [root]
            case .cd(".."):
                path.removeLast()
            case .cd(let name):
                let dir = path.last!.add(name)
                path.append(dir)

            case .ls(let listing):
                path.last!.add(listing)
            }
        }
    }
}

// MARK: - Part 1

print("Day 07:")

enum Part1 {
    static func directories(under size: Int, startingFrom directory: Directory) -> [Directory] {
        let subdirs = directory.directories.flatMap { directories(under: size, startingFrom: $0) }
        if directory.size <= size {
            return [directory] + subdirs
        } else {
            return subdirs
        }
    }

    static func run(_ source: InputData) {
        let input = source.data
        let commands = Command.parse(input)
        let root = Directory(name: "/")
        commands.execute(with: root)

        let matchingDirs = directories(under: 100_000, startingFrom: root)
        let total = matchingDirs.map(\.size).reduce(0, +)

        print("Part 1 (\(source)): \(total)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

print("")

enum Part2 {
    static let totalDiskSpace = 70_000_000
    static let minFree = 30_000_000

    static func directories(over size: Int, startingFrom directory: Directory) -> [Directory] {
        let subdirs = directory.directories.flatMap { directories(over: size, startingFrom: $0) }
        if directory.size >= size {
            return [directory] + subdirs
        } else {
            return subdirs
        }
    }

    static func run(_ source: InputData) {
        let input = source.data
        let commands = Command.parse(input)
        let root = Directory(name: "/")
        commands.execute(with: root)

        let used = root.size
        let unused = totalDiskSpace - used
        let needed = minFree - unused

        let candidates = directories(over: needed, startingFrom: root)
        let best = candidates.min(by: { $0.size < $1.size })!

        print("Part 2 (\(source)): \(best.name) - \(best.size)")
    }
}

InputData.allCases.forEach(Part2.run)
