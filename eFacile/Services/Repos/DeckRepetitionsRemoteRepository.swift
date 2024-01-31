//
//  DeckRepetitionsRemoteRepository.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 24/01/2024.
//

import Foundation
import Moya
import Combine

class DeckRepetitionsProvider2 {
    let githubContentService = GithubContentService()
    let fileParser: FileParserProtocol = FileParser()
    let decksOrderer: DecksOrdererProtocol = DecksOrderer()
    
    func fetchDecksWithRepetitions(forCourse course: Course) -> AnyPublisher<[DeckWithRepetitions], MoyaError> {
        let treeItemsForCourse = fetchTreeItems(forCourse: course)
        
        let decksWithRepetitions = treeItemsForCourse
            .map { treeItems in return treeItems.filter{ $0.isFile && $0.name.hasSuffix(".csv") } }
            .flatMap { items in items.publisher }
            .flatMap { [weak self] item -> AnyPublisher<DeckWithRepetitions, MoyaError> in
                return self?.fetchDeckRepetitions(treeItem: item) ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()
        
        let orderedIds = treeItemsForCourse
            .compactMap { treeItems in return treeItems.first { $0.isFile && $0.name == DecsRepoFileStructure.Constants.orderFileName} }
            .flatMap { [weak self] item in
                self?.fetchAndParseOrder(treeItem: item) ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
        
        let orderedDecks = decksWithRepetitions
            .zip(orderedIds) { [decksOrderer] decksWithRepetitions, orderedIds in
                decksOrderer.setDecksOrder(for: decksWithRepetitions, orderedIds: orderedIds)
            }
            .eraseToAnyPublisher()

        return orderedDecks
    }
    
    private func fetchTreeItems(forCourse course: Course) -> AnyPublisher<[TreeItem], MoyaError> {
        let path = DecsRepoFileStructure.decksPath(forCourse: course)
        return githubContentService.treeItemsForDirectory(path: path)
            .eraseToAnyPublisher()
    }
    
    private func fetchDeckRepetitions(treeItem: TreeItem) -> AnyPublisher<DeckWithRepetitions, MoyaError>  {
        guard let urlstring = treeItem.downloadUrl, let url = URL(string: urlstring) else {
            return Empty().eraseToAnyPublisher()
        }
        
        return downloadFile(url: url)
            .compactMap { String(data: $0, encoding: .utf8) }
            .compactMap { [fileParser] content in
                fileParser.parseCSV(fileContent: content)
            }
            .map { headerWithPairs in
                let cardRepetitions = headerWithPairs.pairs.map {
                    CardWithRepetitions(card: .init(native: $0.key, translation: $0.value), lastScores: [])
                }
                
                return DeckWithRepetitions.init(deckInfo: .init(id: treeItem.name, name: headerWithPairs.header), cardsWithRepetitions: cardRepetitions)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchAndParseOrder(treeItem: TreeItem) -> AnyPublisher<[String], MoyaError>  {
        guard let urlstring = treeItem.downloadUrl, let url = URL(string: urlstring) else {
            return Empty().eraseToAnyPublisher()
        }
        
        return downloadFile(url: url)
            .compactMap { String(data: $0, encoding: .utf8) }
            .compactMap { [fileParser] content in
                fileParser.parseSingleInlineItems(fileContent: content)
            }
            .eraseToAnyPublisher()
    }
    
    private func downloadFile(url: URL) -> AnyPublisher<Data, MoyaError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .mapError { MoyaError.underlying($0, nil) }
            .eraseToAnyPublisher()
    }
}


class DeckRepetitionsRemoteRepository: DeckRepetitionsProviderProtocol {
    let baseURL = "https://raw.githubusercontent.com/rafalur/Piacere_decks/main/"
    let italianPath = "italian"
    let indexFileName = "index.txt"

    private let predefinedDeckIds: [String]
    init(deckIds: [String] = []) {
        self.predefinedDeckIds = deckIds
    }

    func fetchDeckRepetitions(deckId: String) async -> DeckWithRepetitions? {
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
    
    private func generateInitialRepetitions(deck: Deck) -> DeckWithRepetitions {
        let repetitions = deck.cards.map { CardWithRepetitions(card: $0, lastScores: []) }
        return .init(deckInfo: deck.info, cardsWithRepetitions: repetitions)
    }
        
    func downloadFile(url: URL) -> AnyPublisher<Data, MoyaError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .mapError { MoyaError.underlying($0, nil) }
            .eraseToAnyPublisher()
    }
    
    private func parseGroupName(content: String) -> String? {
        guard let firstLine = content.components(separatedBy: .newlines).first else { return nil}
                        
        let pattern = "\"group_name\"\\s*,\\s*\"(.*?)\""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
            if let match = regex.firstMatch(in: firstLine, options: [], range: NSRange(location: 0, length: firstLine.count)) {
                let name = String(firstLine[Range(match.range(at: 1), in: firstLine)!])

                return name
            }
            return nil
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
