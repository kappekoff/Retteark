//
//  Kategorier.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import Foundation

struct Kategori: Hashable, Identifiable, Codable{
    var navn: String
    var id: String = UUID().uuidString
    
    init(navn: String) {
        self.navn = navn
    }
}
