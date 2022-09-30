//
//  VisElevTilbakemleding.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 05/09/2022.
//

import SwiftUI


enum VisElevTilbakemleding: Identifiable  {
    case valgtElev(elev: Elev)
    case velgtInstillinger
    case valgtKategorier
    case leggTilNyKlasse
    case leggTilNyPrøve
    
    var id: String {
        switch self {
        case .valgtElev:
            return "valgtElev"
        case .velgtInstillinger:
            return "velgtInstillinger"
        case .valgtKategorier:
            return "valgtKategorier"
        case .leggTilNyKlasse:
            return "leggTilNyklasse"
        case .leggTilNyPrøve:
            return "leggtilNyPrøve"
            
        }
            
    }
}
