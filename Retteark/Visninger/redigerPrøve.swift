//
//  redigerPrøve.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/03/2023.
//

import SwiftUI
import SQLiteData

struct redigerPr_ve: View {
    var prøveId: Prover.ID
    @Binding var visKlassevisningSheet:VisKlassevisningSheet?
    @Binding var prøver: [Prover]
    @Dependency(\.defaultDatabase) var database

    @State var prøvenavn: String = ""
    @State var visEleverKarakter: Bool = false
    
    @State var oppgaver: [Oppgaver] = []
    @State var prøve: Prover? = nil
    var body: some View {
        NavigationStack {
            Section("Om prøven"){
                TextInputField(title: "Prøvenavn", text: $prøvenavn)
                Toggle("Vis karakter til elever", isOn: $visEleverKarakter)
            }
            .onChange(of: prøvenavn) {
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            let midlertidigProve = Prover(id: prøve?.id ?? "", navn: prøve?.navn ?? "", visEleverKarakter: prøve?.visEleverKarakter ?? false, klasseId: prøve?.klasseId ?? "")
                            try  Prover.update(midlertidigProve)
                                .execute(db)
                        }
                    }
                }
            }
            Section("Oppgaver") {
                List() {
                    ForEach($oppgaver) { oppgave in
                        OppgaveVisning(oppgave: oppgave)
                    }
                    .onDelete(perform: slettOppgaveFraListe)
                    Button {
                        Task {
                            await withErrorReporting {
                                try await database.write { db in
                                    let midlertidigOppgave = Oppgaver(id: UUID().uuidString, navn: "", proveId: prøveId, maksPoeng: 1)
                                    try  Oppgaver.insert{midlertidigOppgave}.execute(db)
                                    oppgaver.append(midlertidigOppgave)
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
            prøvenavn = prøve?.navn ?? ""
            visEleverKarakter = prøve?.visEleverKarakter ?? false
        }
        HStack {
            Button("Lukk") {
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
                prøve = try Prover
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
    @Dependency(\.defaultDatabase) var database
    @Binding var oppgave: Oppgaver

    var body: some View {
        HStack {
            TextField("Oppgavenavn", text: $oppgave.navn)
            Spacer()
            NumericTextField("Makspoeng", number: $oppgave.maksPoeng, isDecimalAllowed: true)
        }
        .onChange(of: oppgave) {
            Task {
                await withErrorReporting {
                    try await database.write { db in
                        let midlertidigOppgave = Oppgaver(id: oppgave.id, navn: oppgave.navn, proveId: oppgave.proveId, maksPoeng: oppgave.maksPoeng)
                        try  Oppgaver.update(midlertidigOppgave)
                            .execute(db)
                    }
                }
            }
        }
        
    }
    
}
