//
//  elev.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/07/2022.
//

import Foundation


struct Elev: Identifiable {
    
    let id: Int
    var navn: String
    var karakter: String
    var låstKarakter: Bool
    
    init(id: Int, navn: String, karakter: String = "1"){
        self.id = id
        self.navn  = navn
        self.karakter = karakter
        self.låstKarakter = true
    }
}
