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
    @State private var valgtKlasseID: Klasse.ID?
    @State private var valgtPrøveID: Prøve.ID?
    @State var visElevTilbakemelding: VisElevTilbakemleding? = nil

    
    var body: some View {
        NavigationSplitView(columnVisibility: $visSideKolonner){
            List($klasseOversikt.klasser, selection: $valgtKlasseID) { valgtKlasse in
                HStack {
                    Text(valgtKlasse.navn.wrappedValue)
                    Spacer()
                    Text(valgtKlasse.skoleÅr.wrappedValue)
                }
                .font(.title).bold()
            }
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
                case .leggTilNyKlasse:
                    leggTilNyKlasseVisning(klasseoversikt: klasseOversikt, tekstFraVisma: "", klasseNavn: "", skoleÅr: "",  visElevTilbakemelding: $visElevTilbakemelding)
                default:
                    Text("Du skal aldri komme hit")
                }
            }
        } content:{
            if let valgtKlasseID = valgtKlasseID, let valgtKlasse=klasseOversikt.finnKlasseFraId(id: valgtKlasseID) {
                List(valgtKlasse.prøver, selection: $valgtPrøveID, rowContent: { valgtPrøve in
                    HStack {
                        Text(valgtPrøve.navn)
                    }
                    .font(.title).bold()
                })
                .navigationTitle("Prøver")
                .toolbar(content: {
                    Button {
                        visElevTilbakemelding = .leggTilNyPrøve
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                })
                .sheet(item: $visElevTilbakemelding, onDismiss: { visElevTilbakemelding = nil }) { visElevTilbakemleding in
                    switch visElevTilbakemleding{
                    case .leggTilNyPrøve:
                        leggTilNyPr_veVisning(klasseoversikt: klasseOversikt,KlasseID: valgtKlasseID,  visElevTilbakemelding: $visElevTilbakemelding)
                    default:
                        Text("Du skal aldri komme hit")
                    }
                }
            }
            else {
                Text("Velg klasse")
            }
        } detail: {
            if let valgtPrøveID = valgtPrøveID, let valgtKlasse = klasseOversikt.finnKlasseFraId(id: valgtKlasseID!), let valgtPrøve = valgtKlasse.finnPrøveFraId(id: valgtPrøveID) {
                VStack {
                    Button{
                        klasseOversikt.lagreKlasser()
                    } label: {
                        Text("Lagre")
                    }
                }
                ContentView(prøve: valgtPrøve)
            }
            else {
                Text("Velg prøver")
            }
        }
    }
}

