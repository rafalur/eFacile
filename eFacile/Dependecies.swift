//
//  Dependecies.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 20/01/2024.
//

import Foundation

class Dependencies {
    public static let shared: Dependencies = .init(mocked: false)
    
    let repetitionsProvider: RepetitionsProviderProtocol 
    
    init(mocked: Bool) {
        repetitionsProvider = mocked ? RepetitionsProviderMock() : RepetitionsProviderReactive(course: .init(id: "", name: "", imageUrl: nil))
    }
}
