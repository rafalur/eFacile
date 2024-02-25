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
                .navigationDestination(for: Course.self) { course in
                    DecksListView(viewModel: .init(course: course,
                                                   repetitionsProvider: RepetitionsProviderReactive(course: course)))
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
        }
        .accentColor(Theme.colors.foreground)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(mocked: true)
    }
}
