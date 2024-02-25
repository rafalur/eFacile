//
//  DeckRepetitionsLocalRepository.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 24/01/2024.
//

import Foundation
import Moya
import Combine

class DeckRepetitionsLocalRepository: DeckRepetitionsRepositoryProtocol {
    func fetchDecksWithRepetitions(forCourse course: Course) -> AnyPublisher<[DeckWithRepetitions], Moya.MoyaError> {
        
        let repetitions = loadRepetitions(courseId: course.id)
        
        return Just<[DeckWithRepetitions]>(repetitions)
            .setFailureType(to: MoyaError.self)
            .eraseToAnyPublisher()
    }
    
    
    private func loadRepetitions(courseId: String) -> [DeckWithRepetitions] {
        var repetitions: [DeckWithRepetitions] = .init()

        let deckIds = deckIds(forCourseWithId: courseId)
        for deckId in deckIds {
            if let loadedRepetitions = self.loadFromCSV(courseId: courseId, deckId: deckId) {
                repetitions.append(loadedRepetitions)
            }
        }
        
        return repetitions
    }
    
    private func deckIds(forCourseWithId courseId: String) -> [String] {
        let prefix = "\(courseId)_"
        let suffix = "_results.csv"
        return FilesHelper.allFilesInDocumentsDir()
            .filter { $0.starts(with: prefix) && $0.hasSuffix(suffix) }
            .map { $0.replacingOccurrences(of: prefix, with: "") }
            .map { $0.replacingOccurrences(of: suffix, with: "") }

    }
    
    func save(repetitions: DeckWithRepetitions, courseId: String) {
        saveToCSV(repetitionResults: repetitions.cardsWithRepetitions,
                  deckInfo: repetitions.deckInfo,
                  courseId: courseId)
    }
    
    func save(deckIds: [String]) {
        let fileName = "index.txt"
        
        guard let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) as NSURL else {
            return }
                
        let csvText = deckIds.reduce("") {
            $0 + $1 + "\n"
        }
        
        do {
            try csvText.write(to: path as URL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    func deckIds() async -> [String] {
        print("==== fetching local deck ids")

        let fileName = "index.txt"
        
        guard let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) as URL else {
            return []
        }
                
        guard let data = try? Data(contentsOf: path) else {
            return []
        }
        
        let lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
        
        let deckIds = lines.map { $0.replacingOccurrences(of: "\"", with: "") }
        
        print("==== local deck ids: \(deckIds)")
        
        return deckIds
    }
    
    private func saveToCSV(repetitionResults: [CardWithRepetitions], deckInfo: DeckInfo, courseId: String) {
        let fileName = "\(courseId)_\(deckInfo.id)_results.csv"
        
        guard let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) as NSURL else {
            return }
        
        var csvText = "\(deckInfo.name)\n"
        
        csvText += repetitionResults.reduce("") {
            $0 + $1.toCSVRow() + "\n"
        }
        
        do {
            try csvText.write(to: path as URL, atomically: true, encoding: String.Encoding.utf8)
            print("aaaa savec CSV: \(fileName)")
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    private func loadFromCSV(courseId: String, deckId: String) -> DeckWithRepetitions? {
        let fileName = "\(courseId)_\(deckId)_results.csv"
        
        guard let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) as URL else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        
        var lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
        
        let firstLine = lines.removeFirst()
        
        let deckName = firstLine.replacingOccurrences(of: "\"", with: "")
        
        let pattern = "\"(.*?)\"\\s*,\\s*\"(.*?)\""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let results = lines.compactMap {
            if let match = regex.firstMatch(in: $0, options: [], range: NSRange(location: 0, length: $0.count)) {
                let native = String($0[Range(match.range(at: 1), in: $0)!])
                let translation = String($0[Range(match.range(at: 2), in: $0)!])

                let card = Card(native: native, translation: translation)
                
                let parts = $0.components(separatedBy: ",")
                
                let scores = Array(parts.dropFirst(2)).compactMap { Int($0) }
                
                return CardWithRepetitions(card: card, lastScores: scores)
            }
            return nil
        }

        return .init(deckInfo: .init(id: deckId, name: deckName), cardsWithRepetitions: results)
    }
}
