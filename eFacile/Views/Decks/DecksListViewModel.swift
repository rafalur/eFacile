//
//  DecksListViewModel.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation
import Combine

struct DeckWithFamiliarityInfo {
    let deckRepetitions: DeckWithRepetitions
}

class DecksListViewModel: ObservableObject {
    let course: Course
    let repetitionsProvider: RepetitionsProviderProtocol
    
    @Published var repetitions = [DeckWithRepetitions]()
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(course: Course, repetitionsProvider: RepetitionsProviderProtocol) {
        self.course = course
        self.repetitionsProvider = repetitionsProvider
        
//        repetitionsProvider
//            .repetitionsUpdated
//            .receive(on: RunLoop.main)
//            .sink { [weak self] repetitions in
//                print("===== updated repetitions")
//            self?.repetitions = repetitions
//        }
//        .store(in: &subscriptions)
        
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
        repetitionsProvider.load(fetch: false)
    }
    
    func importDecks() {
        repetitionsProvider.load(fetch: true)
    }
}
