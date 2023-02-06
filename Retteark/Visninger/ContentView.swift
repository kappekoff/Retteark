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
                    Button(action: {
                        viserSheet = .valgtKategorier
                        
                    }, label: {
                        Image(systemName: "squareshape.split.3x3")
                    })
                    .keyboardShortcut("k")
                    Button(action: {
                        viserSheet = .velgtInstillinger
                        
                    }, label: {
                        Image(systemName: "gear")
                    })
                    .keyboardShortcut("i")
                    Button(action: {
                        klasseoversikt.lagreKlasser()
                        
                    }, label: {
                        Image(systemName: "square.and.arrow.down")
                    })
                    .keyboardShortcut("s")
                    Button(action: {
                        for elev in $valgtPrøve.elever {
                            exportPDF(filnavn: $valgtPrøve.navn + " " + elev.navn){
                                elevTilbakemeldingVisning(elev: elev, visElevTilbakemleding: $viserSheet , prøve: $valgtPrøve)
                            } completion: { status, url in
                                if let url = url,status{
                                    print(url)
                                }
                                else {
                                    print("Klarte ikke produsere pdf")
                                }
                            }
                        }
                        
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                    .keyboardShortcut("p")
                    Button(action: {
                        viserSheet = .velgtKlassesammendrag
                        
                    }, label: {
                        Image(systemName: "chart.bar.xaxis")
                    })
                    .keyboardShortcut("p")
                }
                .buttonStyle(.borderedProminent)
                
                .fullScreenCover(item: $viserSheet, onDismiss: {viserSheet = nil}){ viserSheet in
                    switch viserSheet{
                    case .valgtKategorier:
                        kategoriView(viserSheet: $viserSheet, prøve: $valgtPrøve)
                    case .velgtInstillinger:
                        instillinger(prøve: $valgtPrøve, visElevTilbakemleding: $viserSheet)
                    case .velgtKlassesammendrag:
                        Klassesammendrag(visElevTilbakemleding: $viserSheet, prøve: $valgtPrøve)
                            .presentationDetents([.large])
                    default:
                        Text("Du skal aldri komme hit")
                    }
                }
                ScrollView(.horizontal) {
                    poengTabellView(prøve: $valgtPrøve)
                        
                        .onChange(of: $valgtPrøve) { _ in
                            klasseoversikt.lagreKlasser()
                        }
                }
                
            }
        }
        else {
            Text("Velg prøve")
        }
        
    }
}
