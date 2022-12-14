//
//  leggTilNyKlasseVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 21/09/2022.
//

import SwiftUI
    
struct leggTilNyKlasseVisning: View {
    @ObservedObject var klasseoversikt: Klasseoversikt
    @State var tekstFraVisma: String
    @State var klasseNavn: String
    @State var skoleÅr: String
    @State var elever: [Elev] = []
    @Binding var visLeggTilKlasser: Bool
    
    var body: some View {
        NavigationStack {
            TextInputField(title: "Klassenavn", text: $klasseNavn)
            TextInputField(title: "Skoleår", text: $skoleÅr)
            HStack {
                TextInputField(title: "Legg til elever. Kopier undervisningsgruppe fra visma", text: $tekstFraVisma)
                Button {
                    let navnTilElever = vismaTilElever(visma: tekstFraVisma)
                    elever = navnTilElever.enumerated().map({(index, navn) in return Elev(navn: navn)})
                    print(navnTilElever)
                } label: {
                    Image(systemName: "arrow.right.square.fill")
                }
                List() {
                    ForEach($elever, id: \.self) { elev in
                        TextField("Elevnanv", text: elev.navn)
                    }
                    .onDelete(perform: slettElevFraListe)
                    Button {
                        elever.append(Elev(navn: ""))
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }

                }
                .frame(alignment: .leading)
                .navigationTitle("Legg til ny klasse")
            }
        }
        Button("Legg til") {
            klasseoversikt.klasser.append(Klasse(navn: klasseNavn, elever: elever, skoleÅr: skoleÅr))
            klasseoversikt.lagreKlasser()
            visLeggTilKlasser = false
        }
    }
    func slettElevFraListe(at offsets: IndexSet){
        elever.remove(atOffsets: offsets)    }
}
