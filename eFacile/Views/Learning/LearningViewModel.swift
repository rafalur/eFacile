//
//  LearningViewModel.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 08/01/2024.
//

import Foundation
import SwiftUI

enum SentenceLearningState {
    case idle
    case displaySentence
    case displayTranslation
    case currentSessionFinished
}

struct RepeatSessionData: Equatable, Hashable {
    let deck: DeckWithRepetitions
    let course: Course
}

class LearningViewModel: ObservableObject {
    
    @Published var waitingForUserInput: Bool = false
    @Published var score: Int?
    @Published var currentRepetition: CardWithRepetitions? {
        didSet {
            state = .displaySentence
        }
    }
    @Published var state: SentenceLearningState = .idle
    private var sessionResults: [Int] = .init()
    
    var currentSessionFamiliarity: Int {
        let average = Float(sessionResults.reduce(0, +)) / Float(sessionResults.count)
        
        return Int(((average) / 4) * 100)
    }
    
    var sentenceToDisplay: String {
        return currentRepetition?.card.native ?? ""
    }
    
    var translationToDisplay: String {
        if let currentCard = currentRepetition?.card, state == .displayTranslation {
            return currentCard.translation
        }
        return " "
    }
    
    var remaining: Int {
        if let remaining = repetitionsSession?.remaining {
            return remaining
        }
        return 0
    }
    
    private var data: RepeatSessionData
    private var currentSentenceIndex = 0
    private let repetitionsProvider: RepetitionsProviderProtocol
    private var repetitionsSession: RepetitionsSession?
    private var sessionManager: RepetitionsSessionManagerProtocol
    
    init (data: RepeatSessionData,
          repetitionsProvider: RepetitionsProviderProtocol,
          sessionManager: RepetitionsSessionManagerProtocol = RepetitionsSessionManager()) {
        self.data = data
        self.repetitionsProvider = repetitionsProvider
        self.sessionManager = sessionManager
        startSession()
    }
    
    func submitScore(_ score: Int) {
        let score = score - 1
        self.score = score
        
        updateResultsWithScoreForCurrentSentence(score)
        repetitionsProvider.updateDeck(data.deck, courseId: data.course.id)
        sessionResults.append(score)
        
        printResults()
        
        nextSentence()
    }
    
    func showTranslation() {
        withAnimation {
            state = .displayTranslation
        }
    }
    
    func nextSentence() {
        score = nil
        loadRandomSentence()
    }
    
    func startNewSession() {
        startSession()
    }
     
    private func updateResultsWithScoreForCurrentSentence(_ score: Int) {
        var newCardRepetitions = data.deck.cardsWithRepetitions
        
        if let index = newCardRepetitions.firstIndex(where: { $0.card == currentRepetition?.card }) {
            let previousResult = newCardRepetitions.remove(at: index)
            var lastScores = previousResult.lastScores
            if lastScores.count >= 5 {
                lastScores = Array(lastScores.dropFirst())
            }
            lastScores.append(score)
            let newResult = CardWithRepetitions(card: previousResult.card,
                                                      lastScores: lastScores)
            newCardRepetitions.insert(newResult, at: index)
        }
        
        let newDeck = DeckWithRepetitions(deckInfo: data.deck.deckInfo, cardsWithRepetitions: newCardRepetitions)
        data = .init(deck: newDeck, course: data.course)
    }
    
    private func startSession() {
        sessionResults = .init()
        let toRepeat = sessionManager.generateRepetitions(maxNumber: 10, forCurrentResults: data.deck.cardsWithRepetitions)
        repetitionsSession = .init(repetitions: toRepeat)
        loadRandomSentence()
    }
    
    private func loadRandomSentence() {
        currentRepetition = repetitionsSession?.nextRepetition()
        
        if currentRepetition == nil {
            withAnimation {
                repetitionsSession = nil
                state = .currentSessionFinished
            }
        }
    }
    
    private func printResults() {
//        print("\(repetitionsResults.debugDescription)")
    }
}

extension Array where Element == CardWithRepetitions {
    var debugDescription: String {
        var description = ""
        let sorted = self//.sorted { $0.totalScore > $1.totalScore }
        
        description += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
        sorted.forEach {
            description += "\($0.card.native), scores: \($0.lastScores), average: \($0.average)\n"
        }
        description += "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n"
        return description
    }
}
