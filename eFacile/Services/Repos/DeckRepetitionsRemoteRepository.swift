//
//  DeckRepetitionsRemoteRepository.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 24/01/2024.
//

import Foundation
import Moya
import Combine

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
    
    var a = GithubContentService()
    var cancellables = Set<AnyCancellable>()
    
    func fetchCourses() -> AnyPublisher<[Course], MoyaError> {
        a.treeItemsForDirectory(dir: "groups")
            .map { $0.filter{ item in item.type == "dir" } }
            .flatMap { dirs in dirs.publisher }
            .flatMap { dir in
                print("fetch content of \(dir.name)")
                return self.aaa(groupName: dir.name)
            }
            .print("==== aaaa")
            .collect()
            .eraseToAnyPublisher()
            
    }
    
    func aaa(groupName: String) -> AnyPublisher <Course, MoyaError> {
       return a.treeItemsForDirectory(dir: "groups/\(groupName)")
            .compactMap { items in
                return items.first { item in item.name == "index.txt" }?.downloadUrl
            }
            // Output: TreeItem
            .compactMap { URL(string: $0) }
            .flatMap { url in
                return self.downloadFile(url: url)
            }
            .compactMap { String(data: $0, encoding: .utf8) }
            .compactMap { [weak self] content in
                return self?.parseGroupName(content: content)
            }
            .map { Course(id: groupName, name: $0, imageUrl: nil) }
            .eraseToAnyPublisher()
    }
    
    func downloadFile(url: URL) -> AnyPublisher<Data, MoyaError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .mapError { _ in
                return MoyaError.requestMapping("")
            }
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
        
        print("==== fetch deck ids")
        fetchCourses()
            .sink(receiveCompletion: { _ in}) { treeItem in
                print("treee items: \(treeItem)")
            }
            .store(in: &cancellables)
        
        return []
//        print("==== fetching deck ids")
//
//        let url = "\(baseURL)/\(italianPath)/\(indexFileName)"
//        let content = try? String(contentsOf: URL(string: url)!)
//
//        let lines = content?.components(separatedBy: .newlines) ?? []
//
//        let deckIds = lines.map { $0.replacingOccurrences(of: "\"", with: "") }
//            .filter { !$0.isEmpty }
//
//        print("==== IDS: \(deckIds)")
//
//        return deckIds
    }
}
