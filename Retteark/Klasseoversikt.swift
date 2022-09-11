//
//  Klasseoversikt.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import Foundation

class Klasseoversikt: ObservableObject, Codable {
    
    @Published var klasser: [Klasse]
    
    init(){
        self.klasser = [Klasse(navn: "2IMT", elever: elever_test, skoleÅr: "22/23")]
    }
}

var elever_test = [
    Elev(id: 1, navn: "Petter"),
    Elev(id: 2, navn: "Åse"),
    Elev(id: 3, navn: "Stein"),
    Elev(id: 4, navn: "Per"),
    Elev(id: 5, navn: "Lise"),
    Elev(id: 6, navn: "Jinbo"),
    Elev(id: 7, navn: "Ronja"),
    Elev(id: 8, navn: "Ask"),
    Elev(id: 9, navn: "Fredrik"),
    Elev(id: 10, navn: "Adam")
    ]
