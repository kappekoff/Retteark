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
    var elevId: String
    var oppgaveId: String
    
    
    init(id: [Int], poeng: Float, elevId: String, OppgaveId: String) {
        self.id = id;
        self.poeng = poeng
        self.elevId = elevId
        self.oppgaveId = OppgaveId
    }
}
