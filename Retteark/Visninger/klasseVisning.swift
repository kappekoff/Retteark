//
//  klasseVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import SwiftUI

struct klasseVisning: View {
    @StateObject var klasseoversikt: Klasseoversikt
    @State private var visSideKolonner = NavigationSplitViewVisibility.all
    @State private var valgtKlasseID: Klasse.ID?
    @State private var valgtPrøveID: Prøve.ID?
    @State var visLeggTilKlasser: Bool = false
    @State var visLeggTilPrøve: Bool = false

    
    var body: some View {
        NavigationSplitView(columnVisibility: $visSideKolonner){
            List(selection: $valgtKlasseID) {
                ForEach($klasseoversikt.klasseinformasjon.klasser){ valgtKlasse in
                    HStack {
                        Text(valgtKlasse.navn.wrappedValue)
                        Spacer()
                        Text(valgtKlasse.skoleÅr.wrappedValue)
                    }
                    .font(.title).bold()
                }
                .onDelete(perform: slettKlasseFraListe)
            }
            .navigationTitle("Klasser")
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button {
                        visLeggTilKlasser = true
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Text(.init("**Sist lagret:** " + (klasseoversikt.klasseinformasjon.lagret_tidspunkt?.formatted() ?? "")))
                }
                
            })
            .sheet(isPresented: $visLeggTilKlasser, onDismiss: { visLeggTilKlasser = false }) {
                    leggTilNyKlasseVisning(klasseoversikt: klasseoversikt,tekstFraVisma: "", klasseNavn: "", skoleÅr: "",  visLeggTilKlasser: $visLeggTilKlasser)
            }
        } content:{
            if let valgtKlasseID = valgtKlasseID, let valgtKlasse=klasseoversikt.klasseFraId(id: valgtKlasseID) {
                List(valgtKlasse.prøver, selection: $valgtPrøveID, rowContent: { valgtPrøve in
                    HStack {
                        Text(valgtPrøve.navn)
                    }
                    .font(.title).bold()
                })
                .navigationTitle("Prøver")
                .toolbar(content: {
                    Button {
                        visLeggTilPrøve = true
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                })
                .sheet(isPresented: $visLeggTilPrøve, onDismiss: { visLeggTilPrøve = false }) {
                        leggTilNyPr_veVisning(klasseoversikt: klasseoversikt, KlasseID: valgtKlasseID,  visLeggTilPrøve: $visLeggTilPrøve)
                }
            }
            else {
                Text("Velg klasse")
            }
        } detail: {
            ContentView(klasseoversikt: klasseoversikt, valgtKlasseID: valgtKlasseID, valgtPrøveID: valgtPrøveID)
        }
    }
    
    func slettKlasseFraListe(at offsets: IndexSet){
        klasseoversikt.klasseinformasjon.klasser.remove(atOffsets: offsets)
    }
}

