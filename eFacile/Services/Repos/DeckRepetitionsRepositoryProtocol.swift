//
//  DecksRepository.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation
import Moya
import Combine

protocol DeckRepetitionsRepositoryProtocol: DeckRepetitionsProviderProtocol {
    func save(repetitions: DeckWithRepetitions, courseId: String)
    func save(deckIds: [String])
}

protocol DeckRepetitionsProviderProtocol {
    func fetchDecksWithRepetitions(forCourse course: Course) -> AnyPublisher<[DeckWithRepetitions], MoyaError>
}
