//
//  SentencesApp.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 02/01/2024.
//

import SwiftUI

@main
struct EFacileApp: App {
    let decksRepo = DeckRepetitionsRemoteRepository()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
