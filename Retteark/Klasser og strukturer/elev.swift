//
//  elev.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/07/2022.
//

import Foundation


struct Elev: Identifiable, Hashable, Codable {
    
    var id: String = UUID().uuidString
    var navn: String
    var karakter: String
    var låstKarakter: Bool
    var framovermelding: String = ""
    
    init(navn: String, karakter: String = "1"){
        self.navn  = navn
        self.karakter = karakter
        self.låstKarakter = true
    }
}
