//
//  LearningView.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 08/01/2024.
//

import Foundation
import SwiftUI

struct LearningView: View {
    @Namespace var namespace
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    @State private var userTranslation = ""
    
    @StateObject var viewModel: LearningViewModel
    @EnvironmentObject var provider: RepetitionsProviderReactive
    
    var body: some View {
        VStack {
            HStack {
                Text("Sesja")
                    .font(Theme.fonts.bold(20))
                Spacer()
                Text("Pozostało: \(viewModel.remaining)")
                    .font(Theme.fonts.regular(18))
            }
            .padding()
            .foregroundColor(Theme.colors.foreground)
            .background(Theme.colors.backgroundSecondary)
            .compositingGroup()
            .shadow(color: .black.opacity(0.3), radius: 10)
            .zIndex(1)
            
            Spacer()
            if viewModel.state == .currentSessionFinished {
                sessionScoreView()
            } else {
                
                if let cardRepetition = viewModel.currentRepetition {
                    CardView(cardRepetition: cardRepetition, showTranslation: viewModel.translationToDisplay != " " )
                        .padding(40)
                }
            }
            
            Spacer()
            
            if viewModel.state != .currentSessionFinished {
                HStack(alignment: .center) {
                    scoreView()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(Theme.colors.backgroundSecondary)
            }
        }
        .background(Theme.colors.background)
    }
    
    @ViewBuilder
    func scoreView() -> some View {
        switch viewModel.state {
        case .displaySentence:
            showTranslationView
        case .displayTranslation:
            scoreSelectionView
        default: // finished
            EmptyView()
        }
    }
    
    @ViewBuilder
    func sessionScoreView() -> some View {
        VStack(spacing: 20) {
            Text("Wynik sesji")
                .font(Theme.fonts.bold(28))
                .foregroundColor(Theme.colors.foreground)
                .padding(.bottom, 40)
            
            PieChartProgressView(progress: .constant(Double(viewModel.currentSessionFamiliarity) / 100), style: .large)
                .frame(width: 100, height: 100)
                .padding(.bottom, 40)
            
            newSessionButton
            
            finishButton
        }
    }
    
    private var showTranslationView: some View {
        Button {
            viewModel.showTranslation()
        } label: {
            HStack {
                Spacer()
                Text("Pokaż tłumaczenie")
                    .font(Theme.fonts.bold(18))
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                            .fill(Theme.colors.accent)
                    )
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    private var scoreSelectionView: some View {
        HStack {
            ForEach((1...5), id: \.self)  { index in
                ScoreSelectionView(score: index) {
                    viewModel.submitScore(index)
                }
                .matchedGeometryEffect(id: index, in: namespace)
            }
        }
    }
    
    private var newSessionButton: some View {
        Button {
            viewModel.startNewSession()
        } label: {
            Text("Nowa sesja")
                .font(Theme.fonts.bold(18))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .fill(Theme.colors.accent)
                )
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
        }
    }
    
    private var finishButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Koniec")
                .font(Theme.fonts.bold(18))
                .foregroundColor(Theme.colors.foreground)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .stroke(Theme.colors.foreground, lineWidth: 2)
                )
                .padding(.horizontal, 20)
        }
    }
}

struct CardView: View {
    let cardRepetition: CardWithRepetitions
    let showTranslation: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(cardRepetition.card.native)
                .font(Theme.fonts.bold(22))
                .foregroundColor(Theme.colors.foreground)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
            
            if showTranslation {
                Text(cardRepetition.card.translation)
                    .font(Theme.fonts.regular(22))
                    .foregroundColor(Theme.colors.foreground)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .transition(.scale)
            }
        }
        .frame(minHeight: 400)
        .background(Theme.colors.background)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.5), radius: 15, x: 10, y: 10)
        .overlay(alignment: .topTrailing) {
            PieChartProgressView(progress: .constant(Double(cardRepetition.familiarity) / 100), style: .small)
                .frame(width: 20, height: 20)
                .scenePadding([.top, .trailing])
        }
    }
}

struct ScoreSelectionView: View {
    let score: Int
    let onTap: () -> Void
    
    var body: some View {
        Text("\(score)")
            .font(Theme.fonts.bold(20))
            .frame(width: 50, height: 50)
            .background(Theme.colors.accent.opacity(Double(score-1)/4))
            .foregroundColor(Theme.colors.foreground)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Theme.colors.foreground, lineWidth: 2)
            )
            .onTapGesture {
                onTap()
            }
    }
}
