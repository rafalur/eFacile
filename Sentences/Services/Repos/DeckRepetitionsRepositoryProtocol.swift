//
//  DecksRepository.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation

protocol DeckRepetitionsRepositoryProtocol: DeckRepetitionsProviderProtocol {
    func save(repetitions: DeckRepetitions)
    func save(deckIds: [String])
}

protocol DeckRepetitionsProviderProtocol {
    func deckIds() async -> [String]
    func fetchDeckRepetitions(deckId: String) async -> DeckRepetitions?
}
