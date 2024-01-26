//
//  TeacherTests.swift
//  SentencesTests
//
//  Created by Rafal Urbaniak on 08/01/2024.
//

import Foundation
import XCTest
@testable import Sentences

final class TeacherTests: XCTestCase {

    func testExample() throws {
        let inputRepetitions: [CardRepetitionsResult] =  [
            .init(sentence: .init(native: "1", translation: "1"), numberOfRepetitions: 1, totalScore: 1),
            .init(sentence: .init(native: "2", translation: "1"), numberOfRepetitions: 2, totalScore: 2),
            .init(sentence: .init(native: "3", translation: "1"), numberOfRepetitions: 3, totalScore: 6),
            .init(sentence: .init(native: "4", translation: "1"), numberOfRepetitions: 4, totalScore: 8),
            .init(sentence: .init(native: "5", translation: "1"), numberOfRepetitions: 5, totalScore: 10),
            .init(sentence: .init(native: "6", translation: "1"), numberOfRepetitions: 6, totalScore: 18),
            .init(sentence: .init(native: "7", translation: "1"), numberOfRepetitions: 7, totalScore: 35),
            .init(sentence: .init(native: "8", translation: "1"), numberOfRepetitions: 8, totalScore: 40),
            .init(sentence: .init(native: "9", translation: "1"), numberOfRepetitions: 9, totalScore: 45),
            .init(sentence: .init(native: "10", translation: "1"), numberOfRepetitions: 10, totalScore: 50),

        ]
        print(inputRepetitions.debugDescription)
        
        let sut = Teacher(inputRepetitions)
        
//        let sessionResults = sut.createSession(maxNumberOfRepetitions: 10)
//
//        print("aaaa wellKnown: \(sessionResults.wellKnown.debugDescription)")
//        print("aaaa moderatelyKnown: \(sessionResults.moderatelyKnown.debugDescription)")
//        print("aaaa poorlyKnown: \(sessionResults.poorlyKnown.debugDescription)")
        let result = sut.aaa(maxNumberOfRepetitions: 10)
        
        print("aaaa : \(result.debugDescription)")

    }
    
    private func createRepetitions(count: Int) -> [CardRepetitionsResult] {
        var results = [CardRepetitionsResult] ()
        
        var increaseFactor: Int = 1
        
        for i in 0...count-1 {
            let index = i + 1
            results.append(.init(sentence: .init(native: "n\(index)", translation: "t\(index)"), numberOfRepetitions: index, totalScore: index * increaseFactor ))
            increaseFactor += 1
        }
        
        return results
    }
}

