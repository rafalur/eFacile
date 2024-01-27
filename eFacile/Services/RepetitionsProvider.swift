//
//  RepetitionsProvider.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 20/01/2024.
//

import Foundation
import Combine

protocol RepetitionsProviderProtocol {
    func load(fetch: Bool) async
    func updateRepetitions(_ repetitions: DeckRepetitions)
    
    var repetitionsUpdated: AnyPublisher<[DeckRepetitions], Never> { get }
}

class RepetitionsProvider: RepetitionsProviderProtocol, ObservableObject {
    var repetitionsUpdated: AnyPublisher<[DeckRepetitions], Never> {
        return $cachedRepetitions.eraseToAnyPublisher()
    }
    
    private let decksRemoteRepo: DeckRepetitionsProviderProtocol
    private let decksLocalRepo: DeckRepetitionsRepositoryProtocol
    
    @Published var cachedRepetitions: [DeckRepetitions] = .init()
    
    init(decksRemoteRepo: DeckRepetitionsProviderProtocol = DeckRepetitionsRemoteRepository(),
         decksLocalRepo: DeckRepetitionsRepositoryProtocol = DeckRepetitionsLocalRepository()) {
        self.decksRemoteRepo = decksRemoteRepo
        self.decksLocalRepo = decksLocalRepo
    }
    
    func load(fetch: Bool) async {
        cachedRepetitions = []
        if fetch {
            cachedRepetitions = await loadFromRemote(mergeWitchCached: true)
            cachedRepetitions.forEach {
                self.decksLocalRepo.save(repetitions: $0)
            }
        } else {
            cachedRepetitions = await loadRepetitions(repo: decksLocalRepo)
        }
    }
        
    func loadFromRemote(mergeWitchCached: Bool) async  -> [DeckRepetitions] {
        let repetitionsFromRemote = await loadRepetitions(repo: decksRemoteRepo)
        
        decksLocalRepo.save(deckIds: repetitionsFromRemote.map { $0.deckInfo.id } )
        
        if mergeWitchCached {
            let cachedRepetitions = await loadRepetitions(repo: decksLocalRepo)
            
            let updatedRepetitions: [DeckRepetitions] = repetitionsFromRemote.map { remote in
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
    
    func loadRepetitions(repo: DeckRepetitionsProviderProtocol) async -> [DeckRepetitions] {
        let fetchedDeckIds = await repo.deckIds()
        
        var fetchedRepetitions: [DeckRepetitions] = .init()

        for deckId in fetchedDeckIds {
            if let repetitions = await repo.fetchDeckRepetitions(deckId: deckId) {
                fetchedRepetitions.append(repetitions)
            }
        }
        return fetchedRepetitions
    }
    
    func updateRepetitions(_ repetitions: DeckRepetitions) {
        var newRepetitions = cachedRepetitions
        if let index = newRepetitions.firstIndex(where: { repetitions.deckInfo.id == $0.deckInfo.id }) {
            newRepetitions.remove(at: index)
            newRepetitions.insert(repetitions, at: index)
        }
        decksLocalRepo.save(repetitions: repetitions)

        cachedRepetitions = newRepetitions
    }
    
    private func merge(deckRepetitions: DeckRepetitions, with other: DeckRepetitions) -> DeckRepetitions {
        let cardRepetitionsFirst = deckRepetitions.repetitions
        let cardRepetitionsOther = other.repetitions        
        
        var mergedCardRepetitions: [CardRepetitionsResult] = .init()
        
        for cardRepetition in cardRepetitionsFirst {
            if let matching = cardRepetitionsOther.first(where: { $0.card == cardRepetition.card }),
            matching.lastScores.count >= cardRepetition.lastScores.count {
                mergedCardRepetitions.append(matching)
            } else {
                mergedCardRepetitions.append(cardRepetition)
            }
        }

        return .init(deckInfo: deckRepetitions.deckInfo, repetitions: mergedCardRepetitions)
    }
}
