//
//  Karaktergrenser.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 29/11/2022.
//

import Foundation


class Karaktergrense: Hashable, Codable, Identifiable {
    var id = UUID().uuidString
    var karakter: String
    var grense: Float?
    
    
    init(karakter: String, grense: Float) {
        self.karakter = karakter
        self.grense = grense
    }
    
    static func == (lhs: Karaktergrense, rhs: Karaktergrense) -> Bool {
        return (lhs.karakter == rhs.karakter && lhs.grense == lhs.grense)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(karakter)
        hasher.combine(grense)
        hasher.combine(id)
    }
    
}
