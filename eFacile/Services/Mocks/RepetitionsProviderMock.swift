//
//  RepetitionsProviderMock.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 20/01/2024.
//

import Foundation
import Combine

class RepetitionsProviderMock: RepetitionsProviderProtocol {
    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never>  {
        return Just([]).eraseToAnyPublisher()
    }
    
    func updateRepetitions(_ repetitions: DeckWithRepetitions) {
        
    }
    
    func load(fetch: Bool) {
//        return [
//            .init(deckInfo: .init(id: "1", name: "Podstawowe zwroty"), repetitions: Array(repeating: CardRepetitionsResult(card: .init(native: "1", translation: "2"), lastScores: [1]), count: 25))
//        ]
    }
}
