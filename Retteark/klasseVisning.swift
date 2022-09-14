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
        } content:{
            if let klasseIndex = valgtKlasseIndex, let valgtKlasse = klasseOversikt.klasser[klasseIndex] {
                List(0..<valgtKlasse.prøver.count, selection: $valgtPrøveIndex, rowContent: { valgtPrøveIndex in
                    HStack {
                        Text(klasseOversikt.klasser[valgtKlasseIndex!].prøver[valgtPrøveIndex].navn)
                    }
                    .font(.title).bold()
                })
                .navigationTitle("Prøver")
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

