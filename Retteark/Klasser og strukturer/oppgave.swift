//
//  oppgave.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/07/2022.
//

import Foundation


struct Oppgave: Identifiable, Hashable, Codable {
    
    var id: String = UUID().uuidString
    var navn: String
    var maksPoeng: Float?
    var maksPoengGammelVerdi: Float
    
    init (navn: String, maksPoeng: Float ) {
        self.navn = navn
        self.maksPoeng = maksPoeng
        self.maksPoengGammelVerdi = maksPoeng
        
    }
}
