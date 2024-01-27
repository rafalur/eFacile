//
//  DeckRepetitionsRemoteRepository.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 24/01/2024.
//

import Foundation

class DeckRepetitionsRemoteRepository: DeckRepetitionsProviderProtocol {
    let baseURL = "https://raw.githubusercontent.com/rafalur/Piacere_decks/main/"
    let italianPath = "italian"
    let indexFileName = "index.txt"

    private let predefinedDeckIds: [String]
    init(deckIds: [String] = []) {
        self.predefinedDeckIds = deckIds
    }

    func fetchDeckRepetitions(deckId: String) async -> DeckRepetitions? {
        print("==== fetching deck: \(deckId)")
        let url = "\(baseURL)/\(italianPath)/\(deckId).csv"
        let content = try? String(contentsOf: URL(string: url)!)

        print("==== fetched content: \(content)")

        var lines = content?.components(separatedBy: .newlines) ?? []
        
        let deckName = lines.removeFirst().replacingOccurrences(of: "\"", with: "")
        
        let pattern = "\"(.*?)\"\\s*,\\s*\"(.*?)\""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let cards = lines.compactMap {
            if let match = regex.firstMatch(in: $0, options: [], range: NSRange(location: 0, length: $0.count)) {
                let native = String($0[Range(match.range(at: 1), in: $0)!])
                let translation = String($0[Range(match.range(at: 2), in: $0)!])

                let card = Card(native: native, translation: translation)
                return card
            }
            return nil
        }
        
        let deck = Deck(info: .init(id: deckId, name: deckName), cards: cards)
        
        return generateInitialRepetitions(deck: deck)
    }
    
    private func generateInitialRepetitions(deck: Deck) -> DeckRepetitions {
        let repetitions = deck.cards.map { CardRepetitionsResult(card: $0, lastScores: []) }
        return .init(deckInfo: deck.info, repetitions: repetitions)
    }
    
    
    func deckIds() async -> [String] {
        print("==== fetching deck ids")

        let url = "\(baseURL)/\(italianPath)/\(indexFileName)"
        let content = try? String(contentsOf: URL(string: url)!)

        let lines = content?.components(separatedBy: .newlines) ?? []

        let deckIds = lines.map { $0.replacingOccurrences(of: "\"", with: "") }
            .filter { !$0.isEmpty }
                
        print("==== IDS: \(deckIds)")

        return deckIds
    }
}
