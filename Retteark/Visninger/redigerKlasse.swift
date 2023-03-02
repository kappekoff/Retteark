//
//  redigerKlasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 01/03/2023.
//

import SwiftUI

struct redigerKlasse: View {
    
    var klasseId: Klasse.ID
    @ObservedObject var klasseoversikt: Klasseoversikt
    @State private var tekstFraVisma: String = ""
    @Binding var visKlassevisningSheet:VisKlassevisningSheet?
    var klasseIndex: Int? {
        klasseoversikt.klasseinformasjon.klasser.firstIndex(where: {$0.id==klasseId})
    }
    
    var body: some View {
        NavigationStack {
            if let klasseIndex = klasseIndex {
                TextInputField(title: "Klassenavn", text: $klasseoversikt.klasseinformasjon.klasser[klasseIndex].navn)
                TextInputField(title: "Skoleår", text: $klasseoversikt.klasseinformasjon.klasser[klasseIndex].skoleÅr)
                List() {
                    ForEach($klasseoversikt.klasseinformasjon.klasser[klasseIndex].elever, id: \.self) { elev in
                        TextField("Elevnavn", text: elev.navn)
                    }
                    .onDelete(perform: slettElevFraListe)
                    Button {
                        klasseoversikt.klasseinformasjon.klasser[klasseIndex].elever.append(Elev(navn: ""))
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
                .frame(alignment: .leading)
                .navigationTitle("Lagre endringer")
                }
                Button("Lukk") {
                    visKlassevisningSheet = nil
                }
            }
            

        
        
    }
    func slettElevFraListe(at offsets: IndexSet){
        klasseoversikt.klasseinformasjon.klasser[klasseIndex!].elever.remove(atOffsets: offsets)    }
}
