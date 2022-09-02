//
//  oppgave.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/07/2022.
//

import Foundation


struct Oppgave: Identifiable, Hashable {
    
    let id: Int
    var navn: String
    var maksPoeng: Float?
    var maksPoengGammelVerdi: Float
    
    init (id: Int, navn: String, maksPoeng: Float ) {
        self.id = id
        self.navn = navn
        self.maksPoeng = maksPoeng
        self.maksPoengGammelVerdi = maksPoeng
        
    }
}
