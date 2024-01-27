//
//  DecksListViewModel.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation
import Combine

struct DeckWithFamiliarityInfo {
    let deckRepetitions: DeckRepetitions
}

class DecksListViewModel: ObservableObject {
    private let repetitionsProvider: RepetitionsProviderProtocol
    
    @Published var repetitions = [DeckRepetitions]()
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(repetitionsProvider: RepetitionsProviderProtocol = RepetitionsProvider()) {
        self.repetitionsProvider = repetitionsProvider
        
        repetitionsProvider
            .repetitionsUpdated
            .receive(on: RunLoop.main)
            .sink { [weak self] repetitions in
                print("===== updated repetitions")
            self?.repetitions = repetitions
        }
        .store(in: &subscriptions)
        
        loadDecks()
    }
    
    func loadDecks() {
        Task() { @MainActor in
            await repetitionsProvider.load(fetch: false)
        }
    }
    
    func importDecks() {
        Task() { @MainActor in
            await repetitionsProvider.load(fetch: true)
        }
    }
}
