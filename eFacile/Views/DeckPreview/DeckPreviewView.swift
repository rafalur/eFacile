//
//  DeckPreviewView.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 21/01/2024.
//

import SwiftUI

struct DeckPreviewView: View {
    let previewData: DeckPreviewData
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text(previewData.repetitions.deckInfo.name)
                    .font(Theme.fonts.bold(20))
                    .foregroundColor(Theme.colors.foreground)
                Spacer()
                PieChartProgressView(progress: .constant(Double(previewData.repetitions.familarity) / 100), style: .regular)
                    .frame(width: 40, height: 40)
            }
            .padding()
            .background(Theme.colors.backgroundSecondary)
            .compositingGroup()
            .shadow(color: .black.opacity(0.3), radius: 10)
            .zIndex(1)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(previewData.repetitions.cardsWithRepetitions, id: \.card.id) { cardRepetitions in
                        CardRow(cardRepetitions: cardRepetitions)
                            .background(Theme.colors.background)
                    }
                    Spacer()
                }
            }
        }
        .background(Theme.colors.background)
    }
}

struct CardRow: View {
    let cardRepetitions: CardWithRepetitions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(cardRepetitions.card.native)")
                        .foregroundColor(Theme.colors.foreground)
                    Text("\(cardRepetitions.card.translation)")
                        .foregroundColor(Theme.colors.foregroundSecondary)
                }
                Spacer()
                PieChartProgressView(progress: .constant(Double(cardRepetitions.familiarity) / 100), style: .regular)
                    .frame(width: 40, height: 40)
                
            }
            .font(Theme.fonts.regular(18))
            .padding()

            Divider()
        }
        
    }
}

struct DeckPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let repetitions: [CardWithRepetitions] = [
            .init(card: .init(native: "Hello", translation: "Halo"), lastScores: [1,2,5]),
            .init(card: .init(native: "Ble", translation: "Bla"), lastScores: [4,4,4,4,4])
        ]
        DeckPreviewView(previewData: .init(repetitions: .init(deckInfo: .init(id: "", name: "Podstawowe wyrażenia"), cardsWithRepetitions: repetitions)))
    }
}
