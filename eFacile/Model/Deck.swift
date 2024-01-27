//
//  Deck.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation

struct Deck: Equatable, Identifiable, Hashable {
    var id: String {
        info.id
    }
    let info: DeckInfo
    let cards: [Card]
}
