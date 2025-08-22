//
//  redigerPrøve.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/03/2023.
//

import SwiftUI
import SharingGRDB

struct redigerPr_ve: View {
    var prøveId: Prover.ID
    @Environment(Klasseoversikt.self) var klasseoversikt
    @Binding var visKlassevisningSheet:VisKlassevisningSheet?
    
    @Dependency(\.defaultDatabase) var database

    @State var prøvenavn: String = ""
    @State var visEleverKarakter: Bool = false
    
    @State var oppgaver: [Oppgaver] = []
    @State var prøve: [Prover] = []
    var body: some View {
        @Bindable var klasseoversikt = klasseoversikt
        NavigationStack {
            Section("Om prøven"){
                TextInputField(title: "Prøvenavn", text: $prøvenavn)
                Toggle("Vis karakter til elever", isOn: $visEleverKarakter)
            }
            Section("Oppgaver") {
                List() {
                    ForEach(oppgaver) { oppgave in
                        OppgaveVisning(oppgave: oppgave, navn: oppgave.navn, maksPoeng: oppgave.maksPoeng)
                    }
                    .onDelete(perform: slettOppgaveFraListe)
                    Button {
                        Task {
                            await withErrorReporting {
                                try await database.write { db in
                                    let midlertidigOppgave = Oppgaver(id: UUID().uuidString, navn: "", proveId: prøveId, maksPoeng: 1)
                                    try  Oppgaver.insert{midlertidigOppgave}.execute(db)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
            }.navigationTitle("Legg til Ny prøve")
        }
        .task {
            await hentOppgaver()
            await hentPrøve()
            prøvenavn = prøve.first?.navn ?? ""
            visEleverKarakter = prøve.first?.visEleverKarakter ?? false
        }
        HStack {
            Button("Lukk") {
                klasseoversikt.lagreKlasser()
                visKlassevisningSheet = nil
            }
        }
    }
    
    
    func hentOppgaver() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaver = try Oppgaver
                    .where { $0.id == self.prøveId}
                    .fetchAll(db)
            }
        }
    }
    
    func hentPrøve() async {
        await withErrorReporting {
            try await database.read { db in
                let prøve = try Prover
                    .where { $0.id == self.prøveId }
                    .fetchOne(db)
            }
        }
    }
                

    
    func slettOppgaveFraListe(at offsets: IndexSet){
        let oppgaverSomSkalSlettes = offsets.map { oppgaver[$0] }
        oppgaverSomSkalSlettes.forEach { oppgave in
            Task {
                await withErrorReporting {
                    try await database.write { db in
                        let midlertidigOppgave = Oppgaver(id: oppgave.id, navn: oppgave.navn, proveId: oppgave.proveId, maksPoeng: oppgave.maksPoeng)
                        try  Oppgaver.delete(midlertidigOppgave).execute(db)
                    }
                }
            }
        }
    }
        
}


struct OppgaveVisning: View {
    
    var oppgave: Oppgaver
    @State var navn: String
    @State var maksPoeng: Double?
    
    var body: some View {
        HStack {
            TextField("Oppgavenavn", text: $navn)
            Spacer()
            NumericTextField("Makspoeng", number: $maksPoeng, isDecimalAllowed: true)
        }
    }
    
}
