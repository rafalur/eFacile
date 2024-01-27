//
//  Theme.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 18/01/2024.
//

import Foundation
import SwiftUI

class Theme {
    struct Colors {
        let background: Color = .white
        let backgroundSecondary: Color = Color(hex: 0xdee8ff)
        let foreground: Color = Color(hex: 0x002140)
        let foregroundSecondary: Color =  Color(hex: 0x7b8da5)
        let accent: Color = Color(hex: 0xFF785B)
        let accentSubtle: Color = Color(hex: 0xfbd3ca)
    }
    
    struct Fonts {
        let baseName = "Manrope"
        
        func bold(_ size: CGFloat) -> Font {
            let name = baseName + "-Bold"
            return .custom(name, size: size)
        }
        
        func extraBold(_ size: CGFloat) -> Font {
            let name = baseName + "-ExtraBold"
            return .custom(name, size: size)
        }
        
        
        func regular(_ size: CGFloat) -> Font {
            let name = baseName + "-Regular"
            return .custom(name, size: size)
        }
    }
    
    static let colors: Colors = .init()
    
    static let fonts: Fonts = .init()
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
