//
//  Klasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import Foundation

struct Klasse:  Identifiable, Hashable {
    
    
    var id: String = UUID().uuidString
    var navn: String
    var skoleÅr: String
    var elever: [Elev]
    var prøver: [Prøve]
    
    
    
    init(navn: String, elever: [Elev], skoleÅr: String) {
        self.navn = navn
        self.elever = elever
        self.skoleÅr = skoleÅr
        self.prøver = [Prøve(navn: "Heldagsprøve", elever: elever_test, oppgaver: oppgaver_test, kategorier: kategoier_test)]
    }
    
    static func == (lhs: Klasse, rhs: Klasse) -> Bool {
        return (lhs.id == rhs.id)
    }
    
}
