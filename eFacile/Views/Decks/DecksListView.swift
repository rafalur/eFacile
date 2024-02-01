//
//  DecksListViewe.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation
import SwiftUI
import Combine
import Moya

struct DecksListView: View {
    
    @StateObject var viewModel: DecksListViewModel
    
    var body: some View {
        
        VStack (spacing: 0) {
            Rectangle()
                .frame(height: 10)
                .foregroundColor(Theme.colors.background)
                .background(Theme.colors.background)
                .compositingGroup()
                .shadow(color: .black.opacity(0.2), radius: 5)
                .zIndex(1)
            
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(viewModel.repetitions, id: \.deckInfo.id) { decksRepetitions in
                        
                        NavigationLink.init(value: DeckPreviewData(repetitions: decksRepetitions)) {
                            DeckView(deck: decksRepetitions, course: viewModel.course) {
                                print("tapped")
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
            }
            Divider()
            HStack {
                Spacer()
                Button(action: {
                    viewModel.importDecks()
                }) {
                    Text("Importuj")
                        .font(Theme.fonts.bold(16))
                        .foregroundColor(Theme.colors.foreground)
                        .padding(.horizontal, 20)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                                .stroke(Theme.colors.foreground, lineWidth: 2)
                        )
                }

            }
            .padding()
            .padding(.horizontal)
            .compositingGroup()
            .zIndex(1)
        }
        .background(Theme.colors.background)
    }
}


struct DeckView: View {
    let deck: DeckWithRepetitions
    let course: Course
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            
            Text("\(deck.deckInfo.name)")
                .multilineTextAlignment(.leading)
                .font(Theme.fonts.bold(18))
            
            HStack(alignment: .center) {
                Image("cards")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Theme.colors.accent)
                Text("\(deck.cardsWithRepetitions.count)")
                    .font(Theme.fonts.regular(16))
            }
            .padding(.bottom, 30)
            
            
            
            HStack(alignment: .center) {
                PieChartProgressView(progress: .constant(Double(deck.familarity) / 100), style: .regular)
                    .frame(width: 40, height: 40)
                
                Spacer()
                
                NavigationLink.init(value: RepeatSessionData(deck: deck, course: course)) {
                    Text("Powtórz")
                        .font(Theme.fonts.bold(16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                                .fill(Theme.colors.accent)
                        )
                }
            }
        }
        .foregroundColor(Theme.colors.foreground)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.colors.backgroundSecondary)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.5), radius: 15, x: 15, y: 15)
    }
}


struct DeckList_Previews: PreviewProvider {
    static var previews: some View {
        DecksListView(viewModel: .init(course: .init(id: "1", name: "Test name", imageUrl: nil)))
    }
}

class DecksRepositoryMock: DeckRepetitionsRepositoryProtocol {
    func fetchDecksWithRepetitions(forCourse course: Course) -> AnyPublisher<[DeckWithRepetitions], Moya.MoyaError> {
        return Just<[DeckWithRepetitions]>(.init())
            .setFailureType(to: MoyaError.self)
            .eraseToAnyPublisher()
    }
    
    func save(repetitions: DeckWithRepetitions, courseId: String) {
        
    }
    
    func save(deckIds: [String]) {
        
    }
    
    func deckIds() async -> [String] {
        ["1", "2"]
    }
    
    func fetchDeckRepetitions(deckId: String) async -> DeckWithRepetitions? {

        return .init(deckInfo: .init(id: "1", name: "Podstawowe zwroty"),
                     cardsWithRepetitions: Array(repeating:CardWithRepetitions(card: .init(native: "a", translation: "b"), lastScores: [1,2,3,4,5]), count: 10))
    }

}
