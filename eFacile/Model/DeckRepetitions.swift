//
//  DeckRepetitions.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 19/01/2024.
//

import Foundation

struct DeckRepetitions: Equatable, Hashable {
    let deckInfo: DeckInfo
    let repetitions: [CardRepetitionsResult]
    var familarity: Float {
        let calculatedFamiliarity: Float
        
        if repetitions.isEmpty {
            calculatedFamiliarity = 0
        } else {
            let combinedFamiliarity =  Float( repetitions.reduce(0) { $0 + $1.familiarity  } )                  
            calculatedFamiliarity = combinedFamiliarity / Float(repetitions.count)
        }
        
        return calculatedFamiliarity
    }
}
