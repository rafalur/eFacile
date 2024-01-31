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
    func updateRepetitions(_ repetitions: DeckWithRepetitions)
    
    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never> { get }
}


class RepetitionsProviderReactive: RepetitionsProviderProtocol, ObservableObject {
    @Published var decks: [DeckWithRepetitions] = .init()
    
    let fetchTriggerer: PassthroughSubject<Void, Never> = .init()
    
    let repetitionsRepo = DeckRepetitionsProvider2()
    
    private let course: Course
    
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
    
    func updateRepetitions(_ repetitions: DeckWithRepetitions) {
        
    }
    
    private func setupSubscriptions() {
        
        repetitionsRepo.fetchDecksWithRepetitions(forCourse: course)
            .catch { _ in Just<[DeckWithRepetitions]>.init([]) }
            .assign(to: &$decks)

    }
}

class RepetitionsProvider: RepetitionsProviderProtocol, ObservableObject {
    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never> {
        return $cachedRepetitions.eraseToAnyPublisher()
    }
    
    private let decksRemoteRepo: DeckRepetitionsProviderProtocol
    private let decksLocalRepo: DeckRepetitionsRepositoryProtocol
    
    @Published var cachedRepetitions: [DeckWithRepetitions] = .init()
    
    init(decksRemoteRepo: DeckRepetitionsProviderProtocol = DeckRepetitionsRemoteRepository(),
         decksLocalRepo: DeckRepetitionsRepositoryProtocol = DeckRepetitionsLocalRepository()) {
        self.decksRemoteRepo = decksRemoteRepo
        self.decksLocalRepo = decksLocalRepo
    }
    
    func load(fetch: Bool) {
//        cachedRepetitions = []
//        if fetch {
//            cachedRepetitions = await loadFromRemote(mergeWitchCached: true)
//            cachedRepetitions.forEach {
//                self.decksLocalRepo.save(repetitions: $0)
//            }
//        } else {
//            cachedRepetitions = await loadRepetitions(repo: decksLocalRepo)
//        }
    }
        
    func loadFromRemote(mergeWitchCached: Bool) async  -> [DeckWithRepetitions] {
        let repetitionsFromRemote = await loadRepetitions(repo: decksRemoteRepo)
        
        decksLocalRepo.save(deckIds: repetitionsFromRemote.map { $0.deckInfo.id } )
        
        if mergeWitchCached {
            let cachedRepetitions = await loadRepetitions(repo: decksLocalRepo)
            
            let updatedRepetitions: [DeckWithRepetitions] = repetitionsFromRemote.map { remote in
                if let matchedCachedRepetitions = cachedRepetitions.first(where: { remote.deckInfo.id == $0.deckInfo.id }) {
                    return merge(deckRepetitions: remote, with: matchedCachedRepetitions)
                } else {
                    return remote
                }
            }

            return updatedRepetitions
        } else {
            return repetitionsFromRemote
        }
    }
    
    func loadRepetitions(repo: DeckRepetitionsProviderProtocol) async -> [DeckWithRepetitions] {
        let fetchedDeckIds = await repo.deckIds()
        
        var fetchedRepetitions: [DeckWithRepetitions] = .init()

        for deckId in fetchedDeckIds {
            if let repetitions = await repo.fetchDeckRepetitions(deckId: deckId) {
                fetchedRepetitions.append(repetitions)
            }
        }
        return fetchedRepetitions
    }
    
    func updateRepetitions(_ repetitions: DeckWithRepetitions) {
        var newRepetitions = cachedRepetitions
        if let index = newRepetitions.firstIndex(where: { repetitions.deckInfo.id == $0.deckInfo.id }) {
            newRepetitions.remove(at: index)
            newRepetitions.insert(repetitions, at: index)
        }
        decksLocalRepo.save(repetitions: repetitions)

        cachedRepetitions = newRepetitions
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
