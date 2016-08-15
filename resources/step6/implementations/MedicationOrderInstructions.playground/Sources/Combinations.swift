//
//  Permutations.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

public extension SequenceType where Self.Generator.Element: SequenceType {
    public var combinations: Combinations<Generator.Element.Generator.Element> {
        return Combinations(self.map ({ $0 }))
    }
}

public struct Combinations<T>: SequenceType {
    public let allCombinations: [[T]]

    init < S: SequenceType where S.Generator.Element == T > (_ sequences: S...) {
        self.init(sequences)
    }

    init < S: SequenceType where S.Generator.Element == T > (_ sequences: [S]) {
        var toProcess = sequences

        if sequences.count == 1 {
            self.allCombinations = sequences.first!.map { [$0] }
        } else if let first = toProcess.first {
            toProcess.removeFirst()

            let currentCombinations = first.map { [$0] }
            currentCombinations

            var newCombinations = [[T]]()

            let subPermutations = Combinations(toProcess).allCombinations

            for element in currentCombinations {
                for subPermutation in subPermutations {
                    var combined = element
                    combined.appendContentsOf(subPermutation)

                    newCombinations.append(combined)
                }
            }
            self.allCombinations = newCombinations

        } else {
            allCombinations = []
        }
    }

    public func generate() -> IndexingGenerator<[[T]]> {
        return allCombinations.generate()
    }
}
