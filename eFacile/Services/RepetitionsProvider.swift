//
//  RepetitionsProvider.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 20/01/2024.
//

import Foundation
import Combine
import Moya

protocol RepetitionsProviderProtocol {
    func load(fetch: Bool)
    func updateDeck(_ decks: DeckWithRepetitions, courseId: String)
    
    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never> { get }
}

class RepetitionsProviderReactive: RepetitionsProviderProtocol, ObservableObject {
    @Published var decks: [DeckWithRepetitions] = .init()
    
    let fetchTriggerer: PassthroughSubject<Void, Never> = .init()
    
    let repetitionsRepo = DeckRepetitionsProvider2()
    let localRepo = DeckRepetitionsLocalRepository()
    
    private let course: Course
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(course: Course) {
        self.course = course
        
        setupSubscriptions()
    }

    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never> {
        return $decks.eraseToAnyPublisher()
    }
    
    func load(fetch: Bool) {
        fetchTriggerer.send()
    }
    
    func updateDeck(_ deck: DeckWithRepetitions, courseId: String) {
        localRepo.save(repetitions: deck, courseId: courseId)
        
        if let index = decks.firstIndex(where: { $0.deckInfo.id == deck.deckInfo.id }) {
            decks.remove(at: index)
            decks.insert(deck, at: index)
        }
    }
    
    private func setupSubscriptions() {
        let remoteRepetitions = fetchTriggerer.flatMap { [repetitionsRepo, course] in
            repetitionsRepo.fetchDecksWithRepetitions(forCourse: course)
        }
        
        let localRepetitions = fetchTriggerer.flatMap { [localRepo, course] in
            localRepo.fetchDecksWithRepetitions(forCourse: course)
        }
        
        let mergedRepetitions = remoteRepetitions.zip(localRepetitions) { [weak self] remote, local in
            self?.merge(remote: remote, local: local) ?? []
        }
        
        mergedRepetitions
            .catch { _ in Just<[DeckWithRepetitions]>.init([]) }
            .assign(to: &$decks)
    }
    
    private func merge(remote: [DeckWithRepetitions], local: [DeckWithRepetitions]) -> [DeckWithRepetitions] {
        var merged = [DeckWithRepetitions]()
        
        remote.forEach { deck in
            var mergedDeck = deck
            
            if let matchingLocalDeck = local.first(where: { $0.deckInfo == deck.deckInfo }) {
                mergedDeck = merge(deckRepetitions: deck, with: matchingLocalDeck)
            }
            
            merged.append(mergedDeck)
        }
        
        return merged
    }
    
    private func merge(deckRepetitions: DeckWithRepetitions, with other: DeckWithRepetitions) -> DeckWithRepetitions {
        let cardRepetitionsFirst = deckRepetitions.cardsWithRepetitions
        let cardRepetitionsOther = other.cardsWithRepetitions
        
        var mergedCardRepetitions: [CardWithRepetitions] = .init()
        
        for cardRepetition in cardRepetitionsFirst {
            if let matching = cardRepetitionsOther.first(where: { $0.card == cardRepetition.card }),
            matching.lastScores.count >= cardRepetition.lastScores.count {
                mergedCardRepetitions.append(matching)
            } else {
                mergedCardRepetitions.append(cardRepetition)
            }
        }

        return .init(deckInfo: deckRepetitions.deckInfo, cardsWithRepetitions: mergedCardRepetitions)
    }
}
