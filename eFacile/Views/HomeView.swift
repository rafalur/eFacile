//
//  HomeView.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingDetailView = false
    private let mocked: Bool
    init(mocked: Bool = false) {
        self.mocked = mocked
    }
    

    
    var body: some View {
        NavigationStack {
            
            CoursesView(viewModel: .init())
//            DecksListView(viewModel: .init(repetitionsProvider: Dependencies.shared.repetitionsProvider ))
//                .navigationDestination(for: DeckRepetitions.self) { deckRepetitions in
//                    LearningView(viewModel: .init(deckRepetitions: deckRepetitions, repetitionsProvider: Dependencies.shared.repetitionsProvider))
//                        .toolbarBackground(.hidden, for: .navigationBar)
//                }
                .navigationDestination(for: DeckPreviewData.self) { data in
                    DeckPreviewView(previewData: data)
                        .toolbarBackground(.hidden, for: .navigationBar)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("e")
                                .font(Theme.fonts.regular(24))
                            + Text("Facile")
                                .font(Theme.fonts.extraBold(24))
                        }
                        .foregroundColor(Theme.colors.foreground)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)

//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarBackground(Theme.colors.background, for: .navigationBar)
                
        }
        .toolbarBackground(

                        // 1
                        Color.pink,
                        // 2
                        for: .navigationBar)
        .accentColor(Theme.colors.foreground) 
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(mocked: true)
    }
}
