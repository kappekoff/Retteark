//
//  Kategorier.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import Foundation

struct Kategori: Hashable{
    let navn: String
    let id: Int
    
    init(navn: String, id: Int) {
        self.navn = navn
        self.id = id
    }
}
