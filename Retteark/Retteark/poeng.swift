//
//  poeng.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/07/2022.
//

import Foundation

struct Poeng: Identifiable, Hashable, Codable {
    let id: [Int]
    var poeng: Float?
    
    
    init(id: [Int], poeng: Float) {
        self.id = id;
        self.poeng = poeng
    }
}
