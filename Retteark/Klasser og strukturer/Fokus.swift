//
//  Fokus.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/11/2022.
//

import Foundation

enum Fokus: Hashable, Identifiable {
    case poengFokus(id: [Int])
    
    var id:String {
        switch self {
        case .poengFokus:
            return "poengFokus"
        }
    }
}
