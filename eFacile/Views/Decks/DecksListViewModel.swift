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
    private let course: Course
    private let repetitionsProvider: RepetitionsProviderProtocol
    
    private let repo: RepetitionsProviderReactive
    
    @Published var repetitions = [DeckWithRepetitions]()
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(course: Course, repetitionsProvider: RepetitionsProviderProtocol = RepetitionsProvider()) {
        self.course = course
        self.repo = .init(course: course)
        self.repetitionsProvider = repetitionsProvider
        
//        repetitionsProvider
//            .repetitionsUpdated
//            .receive(on: RunLoop.main)
//            .sink { [weak self] repetitions in
//                print("===== updated repetitions")
//            self?.repetitions = repetitions
//        }
//        .store(in: &subscriptions)
        
        repo
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
        repo.load(fetch: false)
    }
    
    func importDecks() {
        repetitionsProvider.load(fetch: true)
    }
}
