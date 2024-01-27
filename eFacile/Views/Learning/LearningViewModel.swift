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

class LearningViewModel: ObservableObject {
    
    @Published var waitingForUserInput: Bool = false
    @Published var score: Int?
    @Published var currentRepetition: CardRepetitionsResult? {
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
    
    private var deckRepetitions: DeckRepetitions
    private var currentSentenceIndex = 0
    private let repetitionsProvider: RepetitionsProviderProtocol
    private var repetitionsSession: RepetitionsSession?
    private var sessionManager: RepetitionsSessionManagerProtocol
    
    init (deckRepetitions: DeckRepetitions,
          repetitionsProvider: RepetitionsProviderProtocol,
          sessionManager: RepetitionsSessionManagerProtocol = RepetitionsSessionManager()) {
        self.deckRepetitions = deckRepetitions
        self.repetitionsProvider = repetitionsProvider
        self.sessionManager = sessionManager
        startSession()
    }
    
    func submitScore(_ score: Int) {
        let score = score - 1
        self.score = score
        
        updateResultsWithScoreForCurrentSentence(score)
        repetitionsProvider.updateRepetitions(deckRepetitions)
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
        var newCardRepetitions = deckRepetitions.repetitions
        
        if let index = newCardRepetitions.firstIndex(where: { $0.card == currentRepetition?.card }) {
            let previousResult = newCardRepetitions.remove(at: index)
            var lastScores = previousResult.lastScores
            if lastScores.count >= 5 {
                lastScores = Array(lastScores.dropFirst())
            }
            lastScores.append(score)
            let newResult = CardRepetitionsResult(card: previousResult.card,
                                                      lastScores: lastScores)
            newCardRepetitions.insert(newResult, at: index)
        }
        
        deckRepetitions = .init(deckInfo: deckRepetitions.deckInfo, repetitions: newCardRepetitions)
    }
    
    private func startSession() {
        sessionResults = .init()
        let toRepeat = sessionManager.generateRepetitions(maxNumber: 10, forCurrentResults: deckRepetitions.repetitions)
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

extension Array where Element == CardRepetitionsResult {
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
