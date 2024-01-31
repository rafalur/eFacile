//
//  RepetitionDebugView.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 08/01/2024.
//

import SwiftUI

struct RepetitionDebugView: View {
    let result: CardWithRepetitions
    let remainingCount: Int
    var body: some View {
        HStack {
            Spacer()
            Text("Repetitions:\n\(result.lastScores.count)")
            Text("Average:\n\(result.average)")
            Text("Remaining:\n\(remainingCount + 1)")
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
    }
}

struct RepetitionDebugView_Previews: PreviewProvider {
    static var previews: some View {
        RepetitionDebugView(result: .init(card: .init(native: "a", translation: "b"), lastScores: [1,2,3,4,5]), remainingCount: 5)
    }
}
