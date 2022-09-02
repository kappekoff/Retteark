//
//  BoolOgId.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import Foundation


struct BoolOgId: Hashable {
    var verdi: Bool
    var id: String = UUID().uuidString
    
    init(verdi: Bool) {
        self.verdi = verdi
    }
}
