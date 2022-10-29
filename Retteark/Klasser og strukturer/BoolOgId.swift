//
//  BoolOgId.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import Foundation


struct BoolOgId: Hashable, Codable {
    var verdi: Bool
    var kategoriId: String
    var oppgaveId: String
    
    init(verdi: Bool, kategoriId: String, oppgaveId: String) {
        self.verdi = verdi
        self.kategoriId = kategoriId
        self.oppgaveId = oppgaveId
    }
}
