//
//  redigerKlasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 01/03/2023.
//

import SwiftUI
import SharingGRDB



struct redigerKlasse: View {
    
    var valgtKlasseID: Klasser.ID
    
    @State private var tekstFraVisma: String = ""
    @Dependency(\.defaultDatabase) var database
    @Binding var visKlassevisningSheet:VisKlassevisningSheet?
    
    @State private var midlertidigKlasseNavn: String = ""
    @State private var midlertidigKlasseSkoleår: String = ""
    
    
    @FetchAll var klasser : [Klasser] = []
    @State var elever: [Elever] = []
    
    
    
    var body: some View {        
        VStack {
            NavigationStack {
                
                TextInputField(title: "Klassenavn", text: $midlertidigKlasseNavn)
                        
                TextInputField(title: "Skoleår", text: $midlertidigKlasseSkoleår)
                Text("Det er \(elever.count) elever")
                List() {
                    ForEach(elever, id: \.id) { elev in
                        ElevView(elev: elev, navn: elev.navn)
                    }
                    .onDelete(perform: slettElevFraListe)
                    Button {
                        Task {
                            await withErrorReporting {
                                try await database.write { db in
                                    let midlertidigElev = Elever(id: UUID().uuidString, navn: "", klasseId: valgtKlasseID)
                                    try  Elever.insert{midlertidigElev}.execute(db)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)                }
                }
                Button("Lukk") {
                    visKlassevisningSheet = nil
                }
                
            }
        }
        .onAppear {
            Task {
                await hentKlasser()
                midlertidigKlasseNavn = klasser.first?.navn ?? ""
                midlertidigKlasseSkoleår = klasser.first?.skoleår ?? ""
            }
            Task {
                await hentElever()
            }
        }
        .onChange(of: [midlertidigKlasseNavn, midlertidigKlasseSkoleår]) { _, _ in
            Task {
                await withErrorReporting {
                    try await database.write { db in
                        let midlertidigKlasse = Klasser(id: valgtKlasseID, navn: midlertidigKlasseNavn, skoleår: midlertidigKlasseSkoleår)
                        try  Klasser.update(midlertidigKlasse).execute(db)
                    }
                }
            }
        }
    }
            
    
    func hentKlasser() async {
        await withErrorReporting {
            try await $klasser.load(
                Klasser
                    .where{ $0.id == self.valgtKlasseID },
                animation: .default
            )
        }
    }
    
    func hentElever() async {
        await withErrorReporting {
            try await database.read { db in
                elever = try Elever
                    .where { $0.klasseId == self.valgtKlasseID }
                    .fetchAll(db)
            }
        }
    }
    
    
    
    
    func slettElevFraListe(at offsets: IndexSet){
        let eleverSomSkalSlettes = offsets.map { elever[$0] }
        eleverSomSkalSlettes.forEach { elev in
            Task {
                await withErrorReporting {
                    try await database.write { db in
                        let midlertidigElev = Elever(id: elev.id, navn: elev.navn, klasseId: elev.klasseId)
                        try  Elever.delete(midlertidigElev).execute(db)
                    }
                }
            }
        }
        
    }
}


struct ElevView: View {
    
    var elev: Elever
    
    @Dependency(\.defaultDatabase) var database
    @State var navn: String
    
    var body: some View {
        TextField("Elevnavn", text: $navn)
            .onChange(of: navn){
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            let midlertidigElever = Elever(id: elev.id, navn: navn, klasseId: elev.klasseId)
                            try  Elever.update(midlertidigElever).execute(db)
                        }
                    }
                }
            }
    }
}
