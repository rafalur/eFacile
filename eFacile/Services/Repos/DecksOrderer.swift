//
//  DecksOrderer.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 31/01/2024.
//

import Foundation

protocol DecksOrdererProtocol {
    func setDecksOrder(for decks: [DeckWithRepetitions], orderedIds: [String]) -> [DeckWithRepetitions]
}

class DecksOrderer: DecksOrdererProtocol {
    func setDecksOrder(for decks: [DeckWithRepetitions], orderedIds: [String]) -> [DeckWithRepetitions] {
        var originalDecks = decks
        
        var orderedDecks = [DeckWithRepetitions]()
        
        orderedIds.forEach { id in
            if let matchingDeckIndex = originalDecks.firstIndex(where: { $0.deckInfo.id == (id  + ".csv") }) {
                orderedDecks.append(originalDecks.remove(at: matchingDeckIndex))
            }
        }
        
        if !originalDecks.isEmpty {
            print("Ordering info not found for ids: \(originalDecks.map { $0.deckInfo.id } )")
        }
        
        // let's add these decks anyway
        orderedDecks.append(contentsOf: originalDecks)
        
        return orderedDecks
    }
}
