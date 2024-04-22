//
//  redigerKlasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 01/03/2023.
//

import SwiftUI

struct redigerKlasse: View {
    
    var klasseId: Klasse.ID
    
    @Environment(Klasseoversikt.self) var klasseoversikt
    @State private var tekstFraVisma: String = ""
    
    @Binding var visKlassevisningSheet:VisKlassevisningSheet?
    var klasseIndex: Int? {
        klasseoversikt.klasseinformasjon.klasser.firstIndex(where: {$0.id==klasseId})
    }
    @State private var midlertidigeElever: [Elev] = []
    var body: some View {
        @Bindable var klasseoversikt = klasseoversikt
        NavigationStack {
            if let klasseIndex = klasseIndex {
                TextInputField(title: "Klassenavn", text: $klasseoversikt.klasseinformasjon.klasser[klasseIndex].navn)
                TextInputField(title: "Skoleår", text: $klasseoversikt.klasseinformasjon.klasser[klasseIndex].skoleÅr)
                List() {
                    ForEach($klasseoversikt.klasseinformasjon.klasser[klasseIndex].elever, id: \.id) { elev in

                        TextField("Elevnavn", text: elev.navn)
                    }
                    .onDelete(perform: slettElevFraListe)
                    Button {
                        klasseoversikt.klasseinformasjon.klasser[klasseIndex].elever.append(Elev(navn: ""))
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
            }
            Button("Lukk") {
                klasseoversikt.lagreKlasser()
                visKlassevisningSheet = nil
            }
            .onAppear {
                midlertidigeElever = klasseoversikt.klasseinformasjon.klasser.first(where: {$0.id==klasseId})?.elever ?? []
            }
            .onChange(of: midlertidigeElever) {
                if let klasseIndex = klasseIndex {
                    klasseoversikt.klasseinformasjon.klasser[klasseIndex].elever = midlertidigeElever
                }
            }
        }

        

        
        
    }
    func slettElevFraListe(at offsets: IndexSet){
        klasseoversikt.klasseinformasjon.klasser[klasseIndex!].elever.remove(atOffsets: offsets)    }
}
