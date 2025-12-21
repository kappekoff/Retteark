//
//  leggTilNyKlasseVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 21/09/2022.
//

import SwiftUI
import SQLiteData
    
struct leggTilNyKlasseVisning: View {
    @Dependency(\.defaultDatabase) var database
    @State var tekstFraVisma: String
    @State var klasseNavn: String
    @State var skoleÅr: String
    @State var elever: [Elever] = []
    @Binding var visKlassevisningSheet: VisKlassevisningSheet?
    @Binding var klasser: [Klasser]
    
    var body: some View {
        NavigationStack {
            TextInputField(title: "Klassenavn", text: $klasseNavn)
            TextInputField(title: "Skoleår", text: $skoleÅr)
            HStack {
                TextInputField(title: "Legg til elever. Kopier undervisningsgruppe fra visma", text: $tekstFraVisma)
                Button {
                    let navnTilElever = vismaTilElever(visma: tekstFraVisma)
                    elever = navnTilElever.enumerated().map({(index, navn) in return Elever(id: UUID().uuidString, navn: navn)})
                    print(navnTilElever)
                } label: {
                    Image(systemName: "arrow.right.square.fill")
                }
                VStack {
                    Text("Det er \(elever.count) elever")
                    List() {
                        
                        ForEach($elever) { elev in
                            TextField("Elevnanv", text: elev.navn)
                        }
                        .onDelete(perform: slettElevFraListe)
                        Button {
                            elever.append(Elever(id: UUID().uuidString, navn: ""))
                        } label: {
                            Image(systemName: "plus.circle").foregroundColor(.green)
                        }
                    }
                    .frame(alignment: .leading)
                    .navigationTitle("Legg til ny klasse")
                }
            }
        }
        HStack {
            Button("Avbryt") {
                visKlassevisningSheet = nil
            }
            Button("Legg til") {
                let klasseId = UUID().uuidString
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            let midlertidigKlasse = Klasser(id: klasseId, navn: klasseNavn, skoleår: skoleÅr)
                            try  Klasser.insert{midlertidigKlasse}.execute(db)
                            klasser.append(midlertidigKlasse)
                        }
                    }
                }
                for elev in elever {
                    Task {
                        await withErrorReporting {
                            try await database.write { db in
                                let midlertidigElev = Elever(id: elev.id, navn: elev.navn, klasseId: klasseId)
                                try  Elever.insert{midlertidigElev}.execute(db)
                            }
                        }
                    }
                }
                visKlassevisningSheet = nil
            }
        }
        
    }
    
    func slettElevFraListe(at offsets: IndexSet){
        elever.remove(atOffsets: offsets)
    }
}
