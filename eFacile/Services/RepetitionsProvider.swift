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
    func updateRepetitions(_ repetitions: DeckWithRepetitions, courseId: String)
    
    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never> { get }
}


class RepetitionsProviderReactive: RepetitionsProviderProtocol, ObservableObject {
    func updateRepetitions(_ repetitions: DeckWithRepetitions, courseId: String) {
        
    }
    
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
    
    func updateRepetitions(_ repetitions: DeckWithRepetitions) {
        localRepo.save(repetitions: repetitions,courseId: course.id)
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
            .print("zzzzzz")
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

class RepetitionsProvider: RepetitionsProviderProtocol, ObservableObject {
    var repetitionsUpdated: AnyPublisher<[DeckWithRepetitions], Never> {
        return $cachedRepetitions.eraseToAnyPublisher()
    }
    
    private let decksLocalRepo: DeckRepetitionsRepositoryProtocol
    
    @Published var cachedRepetitions: [DeckWithRepetitions] = .init()
    
    init(decksLocalRepo: DeckRepetitionsRepositoryProtocol = DeckRepetitionsLocalRepository()) {
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
        
//    func loadFromRemote(mergeWitchCached: Bool) async  -> [DeckWithRepetitions] {
//        let repetitionsFromRemote = await loadRepetitions(repo: decksRemoteRepo)
//
//        decksLocalRepo.save(deckIds: repetitionsFromRemote.map { $0.deckInfo.id } )
//
//        if mergeWitchCached {
//            let cachedRepetitions = await loadRepetitions(repo: decksLocalRepo)
//
//            let updatedRepetitions: [DeckWithRepetitions] = repetitionsFromRemote.map { remote in
//                if let matchedCachedRepetitions = cachedRepetitions.first(where: { remote.deckInfo.id == $0.deckInfo.id }) {
//                    return merge(deckRepetitions: remote, with: matchedCachedRepetitions)
//                } else {
//                    return remote
//                }
//            }
//
//            return updatedRepetitions
//        } else {
//            return repetitionsFromRemote
//        }
//    }
    
//    func loadRepetitions(repo: DeckRepetitionsProviderProtocol) async -> [DeckWithRepetitions] {
//        let fetchedDeckIds = await repo.deckIds()
//
//        var fetchedRepetitions: [DeckWithRepetitions] = .init()
//
//        for deckId in fetchedDeckIds {
//            if let repetitions = await repo.fetchDeckRepetitions(deckId: deckId) {
//                fetchedRepetitions.append(repetitions)
//            }
//        }
//        return fetchedRepetitions
//    }
    
    func updateRepetitions(_ repetitions: DeckWithRepetitions, courseId: String) {
        var newRepetitions = cachedRepetitions
        if let index = newRepetitions.firstIndex(where: { repetitions.deckInfo.id == $0.deckInfo.id }) {
            newRepetitions.remove(at: index)
            newRepetitions.insert(repetitions, at: index)
        }
        decksLocalRepo.save(repetitions: repetitions, courseId: courseId)

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
