//
//  klasseVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import SwiftUI

struct klasseVisning: View {
    @StateObject var klasseOversikt: Klasseoversikt
    @State private var visSideKolonner = NavigationSplitViewVisibility.all
    @State private var valgtKlasseIndex: Int?
    @State private var valgtPrøveIndex: Int?
    @State var visElevTilbakemelding: VisElevTilbakemleding? = nil

    
    var body: some View {
        NavigationSplitView(columnVisibility: $visSideKolonner){
            List(0..<klasseOversikt.klasser.count, selection: $valgtKlasseIndex, rowContent: { valgtKlasseIndex in
                HStack {
                    Text(klasseOversikt.klasser[valgtKlasseIndex].navn)
                    Spacer()
                    Text(klasseOversikt.klasser[valgtKlasseIndex].skoleÅr)
                }
                .font(.title).bold()
                

            })
            .navigationTitle("Klasser")
            .toolbar(content: {
                Button {
                    visElevTilbakemelding = .leggTilNyKlasse
                } label: {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
            })
            .sheet(item: $visElevTilbakemelding, onDismiss: { visElevTilbakemelding = nil }) { visElevTilbakemleding in
                switch visElevTilbakemleding{
                case .valgtElev(let elev):
                    Text("skal aldri komme hit .valgtElev")
                case .velgtInstillinger:
                    Text("skal aldri komme hit .velgtInstillinger")
                case .valgtKategorier:
                    Text("skal aldri komme hit .valgtKategorier")
                case .leggTilNyKlasse:
                    leggTilNyKlasseVisning(klasseoversikt: klasseOversikt, tekstFraVisma: "", klasseNavn: "", skoleÅr: "",  visElevTilbakemelding: $visElevTilbakemelding)
                }
            }
        } content:{
            if let klasseIndex = valgtKlasseIndex, let valgtKlasse = klasseOversikt.klasser[klasseIndex] {
                List(0..<valgtKlasse.prøver.count, selection: $valgtPrøveIndex, rowContent: { valgtPrøveIndex in
                    HStack {
                        Text(klasseOversikt.klasser[valgtKlasseIndex!].prøver[valgtPrøveIndex].navn)
                    }
                    .font(.title).bold()
                })
                .navigationTitle("Prøver")
                .toolbar(content: {
                    Button {
                        visElevTilbakemelding = .leggTilNyKlasse
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                })
            }
            else {
                Text("Velg klasse")
            }
        } detail: {
            if let prøveIndex = valgtPrøveIndex, let klasseIndex = valgtKlasseIndex {
                VStack {
                    Button{
                        klasseOversikt.lagreKlasser()
                    } label: {
                        Text("Lagre")
                    }
                }
                ContentView(prøve: klasseOversikt.klasser[klasseIndex].prøver[prøveIndex])
            }
            else {
                Text("Velg prøver")
            }
        }
    }
}

