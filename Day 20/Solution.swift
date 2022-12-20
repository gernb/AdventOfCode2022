//
//  Solution.swift
//  Day 20
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Part1 {
    typealias EncryptedFile = [(value: Int, id: Int)]
    static func mix(_ encryptedFile: EncryptedFile, with source: EncryptedFile) -> EncryptedFile {
        let count = encryptedFile.count - 1
        var decryptedFile = encryptedFile
        for number in source {
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
        return decryptedFile
    }

    static func run(_ source: InputData) {
        let original = source.numbers.enumerated().map { (value: $0.element, id: $0.offset) }
        let decryptedFile = mix(original, with: original).map(\.value)
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
        let decryptionKey = 811589153
        let original = source.numbers.enumerated().map { (value: $0.element * decryptionKey, id: $0.offset) }
        var decryptedNumbers = original
        for _ in 1 ... 10 {
            decryptedNumbers = Part1.mix(decryptedNumbers, with: original)
        }
        let decryptedFile = decryptedNumbers.map(\.value)
        let indexOfZero = decryptedFile.firstIndex(of: 0)!
        let coords = [1000, 2000, 3000].map {
            decryptedFile[(indexOfZero + $0) % decryptedFile.count]
        }
        print(coords)

        print("Part 2 (\(source)): \(coords.reduce(0, +))")
    }
}
