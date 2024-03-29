//
//  Teacher.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 07/01/2024.
//

import Foundation



protocol RepetitionsSessionManagerProtocol {
    func generateRepetitions(maxNumber: Int, forCurrentResults: [CardWithRepetitions]) -> [CardWithRepetitions]
}

struct RepetitionGroups {
    let wellKnown: [CardWithRepetitions]
    let moderatelyKnown: [CardWithRepetitions]
    let poorlyKnown: [CardWithRepetitions]
}

struct RepetitionsSession {
    var repetitions: [CardWithRepetitions]
    
    var remaining: Int {
        return repetitions.count
    }
    
    init(repetitions: [CardWithRepetitions]) {
        self.repetitions = repetitions
    }
    
    mutating func nextRepetition() -> CardWithRepetitions? {
        guard !repetitions.isEmpty else { return nil }
        return repetitions.removeFirst()
    }
}

class RepetitionsSessionManager: RepetitionsSessionManagerProtocol {
    func generateRepetitions(maxNumber: Int, forCurrentResults results: [CardWithRepetitions]) -> [CardWithRepetitions] {
        let groups = createRepetitionGroups(forCurrentResults: results)
        
        var allWellKnown = groups.wellKnown.shuffled()
        var allModeratelyKnown = groups.moderatelyKnown.shuffled()
        var allPoorlyKnown = groups.poorlyKnown.shuffled()

        let expectedWellKnown: Int = 2
        let expectedModeratelyKnown: Int = 4
        let expectedPoorlyKnown: Int = 4
        
        var wellKnownToInclude = [CardWithRepetitions]()
        var moderatelyKnownToInclude = [CardWithRepetitions]()
        var poorlyKnownToInclude = [CardWithRepetitions]()
        
        for _ in 0...expectedWellKnown - 1 {
            if !allWellKnown.isEmpty {
                wellKnownToInclude.append(allWellKnown.removeFirst())
            } else if !allModeratelyKnown.isEmpty {
                wellKnownToInclude.append(allModeratelyKnown.removeFirst())
            } else if !allPoorlyKnown.isEmpty {
                wellKnownToInclude.append(allPoorlyKnown.removeFirst())
            }
        }
        
        for _ in 0...expectedModeratelyKnown - 1 {
            if !allModeratelyKnown.isEmpty {
                moderatelyKnownToInclude.append(allModeratelyKnown.removeFirst())
            } else if !allPoorlyKnown.isEmpty {
                moderatelyKnownToInclude.append(allPoorlyKnown.removeFirst())
            } else if !allWellKnown.isEmpty {
                moderatelyKnownToInclude.append(allWellKnown.removeFirst())
            }
        }
        
        for _ in 0...expectedPoorlyKnown - 1 {
            if !allPoorlyKnown.isEmpty {
                poorlyKnownToInclude.append(allPoorlyKnown.removeFirst())
            } else if !allModeratelyKnown.isEmpty {
                poorlyKnownToInclude.append(allModeratelyKnown.removeFirst())
            } else if !allWellKnown.isEmpty {
                poorlyKnownToInclude.append(allWellKnown.removeFirst())
            }
        }
        
        
        return (wellKnownToInclude + moderatelyKnownToInclude + poorlyKnownToInclude).shuffled()
    }
    
    private func createRepetitionGroups(forCurrentResults results: [CardWithRepetitions]) -> RepetitionGroups {
        let grouped = results.goupByAverage(maxAverage: 4, numberOfGroups: 3)
        
        return .init(wellKnown: grouped[safe: 2] ?? [],
                     moderatelyKnown: grouped[safe: 1] ?? [],
                     poorlyKnown: grouped[safe: 0] ?? [])
    }
}

extension Array where Element == CardWithRepetitions {
    func goupByAverage(maxAverage: Float, numberOfGroups: Int) -> [[CardWithRepetitions]] {
        guard self.count > 0 else { return .init() }
        
        var grouped = [[CardWithRepetitions]]()
        
        let sorted = self.sorted { $0.average < $1.average }
        
        var remaining = sorted
        
        let rangeStep = maxAverage / Float(numberOfGroups)
        
        var rangeLimit = rangeStep
        
        for _ in 1...numberOfGroups-1 {
            if let index = remaining.firstIndex(where: { $0.average >= rangeLimit }) {
                grouped.append(Array(remaining.prefix(index)))
                remaining = Array(remaining.dropFirst(index))

            }
            rangeLimit += rangeStep
        }
        
        grouped.append(remaining)
        
        return grouped
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
