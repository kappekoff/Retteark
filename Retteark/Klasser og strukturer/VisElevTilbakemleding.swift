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
    case velgtKlassesammendrag
    
    var id: String {
        switch self {
        case .valgtElev:
            return "valgtElev"
        case .velgtInstillinger:
            return "velgtInstillinger"
        case .valgtKategorier:
            return "valgtKategorier"
        case .velgtKlassesammendrag:
            return "velgtKlassesammendrag"
            
        }
            
    }
}


enum VisKlassevisningSheet: Identifiable{
    case leggTilKlasse
    case leggTilPrøve
    case redigerKlasse(klasse: Klasse)
    case redigerPrøve(prøve: Prøve)
    
    var id: String {
        switch self {
        case .leggTilKlasse:
            return "leggTilKlasse"
        case .leggTilPrøve:
            return "leggTilPrøve"
        case .redigerKlasse:
            return "redigerKlasse"
        case .redigerPrøve:
            return "redigerPrøve"
        }
    }
}
