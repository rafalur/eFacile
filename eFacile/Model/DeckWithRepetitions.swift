//
//  DeckRepetitions.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 19/01/2024.
//

import Foundation

struct DeckWithRepetitions: Equatable, Hashable {
    let deckInfo: DeckInfo
    let cardsWithRepetitions: [CardWithRepetitions]
    var familarity: Float {
        let calculatedFamiliarity: Float
        
        if cardsWithRepetitions.isEmpty {
            calculatedFamiliarity = 0
        } else {
            let combinedFamiliarity =  Float( cardsWithRepetitions.reduce(0) { $0 + $1.familiarity  } )                  
            calculatedFamiliarity = combinedFamiliarity / Float(cardsWithRepetitions.count)
        }
        
        return calculatedFamiliarity
    }
}
