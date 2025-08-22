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
    var maksPoeng: Double?
    var gammelMaksPoeng: Double?
    
    init (navn: String, maksPoeng: Double ) {
        self.navn = navn
        self.maksPoeng = maksPoeng 
        self.gammelMaksPoeng = maksPoeng
    }
}
