//
//  SentenceRepetitionsResult.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 08/01/2024.
//

import Foundation

struct CardWithRepetitions: Equatable, Hashable {
    let card: Card
    let lastScores: [Int]
    
    var average: Float {
        guard lastScores.count > 0 else {
            return 0
        }
        
        var scores = lastScores
        
        if lastScores.count < 5 {
            scores += Array.init(repeating: 0, count: 5 - lastScores.count)
        }
        
        return Float(scores.reduce(0, +)) / Float(scores.count)
    }
    
    var familiarity: Int {
        guard average > 0 else {
            return 0
        }
        
        let result = Int(((average) / 4) * 100)
        
        return result
    }
    
    func toCSVRow() -> String {
        let scoresPart = lastScores.map {"\($0)"}
        
        return (["\"\(card.native)\"", "\"\(card.translation)\""] + scoresPart).joined(separator: ",")
    }
}
