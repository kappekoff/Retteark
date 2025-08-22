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
    case viserProgressView
    
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
        case .viserProgressView:
          return "viserProgressView"
            
        }
            
    }
}


enum VisKlassevisningSheet: Identifiable{
    case leggTilKlasse
    case leggTilPrøve
    case redigerKlasse(klasseid: Klasser.ID)
    case redigerPrøve(prøveid: Prøve.ID)
    
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
