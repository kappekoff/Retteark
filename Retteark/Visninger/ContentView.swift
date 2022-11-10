//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var klasseoversikt:Klasseoversikt
    var valgtKlasseID: Klasse.ID?
    var valgtPrøveID: Prøve.ID?
    @State var viserSheet: VisElevTilbakemleding? = nil
    @State var tabellBredde: CGFloat = 0.0
    
    var body: some View {
        if let valgtPrøveID = valgtPrøveID, let valgtKlasse = klasseoversikt.klasseFraId(id: valgtKlasseID!), let $valgtPrøve = valgtKlasse.finnPrøveFraId(id: valgtPrøveID) {
            VStack {
                HStack {
                    Button("Kategorier") {
                        viserSheet = .valgtKategorier
                    }
                    .keyboardShortcut("k")
                    Button("Instillinger") {
                        viserSheet = .velgtInstillinger
                    }
                    .keyboardShortcut("i")
                    Button{
                        klasseoversikt.lagreKlasser()
                    } label: {
                        Text("Lagre")
                    }
                    .keyboardShortcut("s")
                }
                .buttonStyle(.borderedProminent)
                
                .sheet(item: $viserSheet, onDismiss: {viserSheet = nil}){ viserSheet in
                    switch viserSheet{
                    case .valgtKategorier:
                        kategoriView(viserSheet: $viserSheet, prøve: $valgtPrøve)
                    case .velgtInstillinger:
                        instillinger(prøve: $valgtPrøve, visElevTilbakemleding: $viserSheet)
                    default:
                        Text("Du skal aldri komme hit")
                    }
                }
                poengTabellView(prøve: $valgtPrøve)
                
            }
        }
        else {
            Text("Velg prøver")
        }
        
    }
}
