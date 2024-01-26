//
//  Card.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation

struct Card: Equatable, Identifiable, Hashable {
    var id: String {
        native
    }
    let native: String
    let translation: String
}
