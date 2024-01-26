//
//  PieChartProgressView.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 19/01/2024.
//

import Foundation
import SwiftUI

struct PieChartProgressView: View {
    enum Style {
        case small
        case regular
        case large
    }
    
    @Binding var progress: Double // Progress value between 0.0 and 1.0
    let style: Style
    
    private var lineWidth: CGFloat {
        switch style {
        case .small:
            return 6
        case .regular:
            return 8
        case .large:
            return 20

        }
    }
    
    private var fontSize: CGFloat {
        switch style {
        case .small:
            return 6
        case .regular:
            return 14
        case .large:
            return 24
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2.0

            ZStack {
                Circle()
                    .stroke(Theme.colors.foreground.opacity(0.1), lineWidth: lineWidth)
                    .rotationEffect(.radians(-.pi/2))

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.colors.foreground.opacity(0.6), lineWidth: lineWidth)
                    .rotationEffect(.radians(-.pi/2))

                if style != .small {
                    Text("\(Int(progress * 100))")
                        .font(Theme.fonts.extraBold(fontSize))
                        .foregroundColor(Theme.colors.accent)
                }
            }
            .frame(width: radius * 2, height: radius * 2)
        }
    }
}


