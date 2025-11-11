//
//  leggTilNyPrøveVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/09/2022.
//

import SwiftUI
import SharingGRDB

struct leggTilNyPr_veVisning: View {
    @Dependency(\.defaultDatabase) var database
    var klasseID: String
    @Binding var visKlassevisningSheet: VisKlassevisningSheet?
    @State var prøveNavn: String = ""
    @State var oppgaver: [Oppgaver] = [];
    @State var visEleverKarakter = true;
    @State var nyeOppgaver: String = "";
    @State var maksPoeng: Double? = nil
    let proveid = UUID().uuidString
    @FetchAll var elever: [Elever] = []
    
    var body: some View {
        NavigationStack {
            Text("Legg til ny prøve").font(.largeTitle)
            Section("Om prøven"){
                TextInputField(title: "Prøvenavn", text: $prøveNavn)
                Toggle("Vis karakter til elever", isOn: $visEleverKarakter)
            }
            Section("Oppgaver") {
                HStack {
                    TextField("Oppgavenavn: 1-15, 1.a-d", text: $nyeOppgaver)
                        .onSubmit {
                            leggTilNyeOppgaver(prøveId: UUID().uuidString)
                        }
                    NumericTextField("Makspoeng", number: $maksPoeng, isDecimalAllowed: true)
                    Button("Legg til") {
                        leggTilNyeOppgaver(prøveId: proveid)
                    }
                }
                List() {
                    ForEach($oppgaver) { oppgave in
                        HStack {
                            TextField("Oppgavenavn", text: oppgave.navn)
                            Spacer()
                            NumericTextField("Makspoeng", number: oppgave.maksPoeng, isDecimalAllowed: true)
                        }
                        
                    }
                    .onDelete(perform: slettOppgaveFraListe)
                    Button {
                        oppgaver.append(Oppgaver(id: UUID().uuidString, navn: "",  proveId: proveid, maksPoeng: 1, gammelMaksPoeng: 1))
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
            }
            HStack {
                Button("Avbryt") {
                    visKlassevisningSheet = nil
                }
                Button("Legg til") {
                    Task {
                        await withErrorReporting {
                            try await database.write { db in
                                let midlertidigPrøve = Prover(id: proveid, navn: prøveNavn, visEleverKarakter: visEleverKarakter, klasseId: klasseID)
                                try  Prover.insert{midlertidigPrøve}.execute(db)
                            }
                        }
                        await hentElever()
                        for oppgave in oppgaver {
                            await withErrorReporting {
                                try await database.write { db in
                                    let midlertidigOppgave = Oppgaver(id: oppgave.id, navn: oppgave.navn, proveId: proveid, maksPoeng: oppgave.maksPoeng)
                                    try  Oppgaver.insert{midlertidigOppgave}.execute(db)
                                }
                            }
                        }
                        
                        for elev in elever  {
                            let deltakerId = UUID().uuidString
                            await withErrorReporting {
                                try await database.write { db in
                                    let midlertidigDeltaker = Deltakere(id: deltakerId, navn: elev.navn, proveId: proveid, låstKarakter: false, karakter: "", framovermelding: "")
                                    try  Deltakere.insert{midlertidigDeltaker}.execute(db)
                                }
                            }
                            for oppgave in oppgaver {
                                await withErrorReporting {
                                    try await database.write { db in
                                        let midlertidigPoeng = Poenger(oppgaveId: oppgave.id, deltakerId: deltakerId, poeng: "", id: UUID().uuidString)
                                        try  Poenger.insert{midlertidigPoeng}.execute(db)
                                    }
                                }
                            }
                        }
                    }
                    visKlassevisningSheet = nil
                }
                    
            }
        }.navigationTitle("Legg til ny prøve")
    }
    
    func slettOppgaveFraListe(at offsets: IndexSet){
        oppgaver.remove(atOffsets: offsets)
    }
    
    func leggTilNyeOppgaver(prøveId: String) {
        let listeMedNyeOppgaver:[Oppgaver] = oppgaverFraListeMedOppgavenavn(listeMedOppgavenavn: lagOppgaver(input: nyeOppgaver), maksPoeng: maksPoeng, prøveId: prøveId)
        oppgaver.append(contentsOf: listeMedNyeOppgaver)
        nyeOppgaver = ""
    }
    
    func hentElever() async {
        await withErrorReporting {
            try await $elever.load(
                Elever
                    .where{ $0.klasseId == self.klasseID },
                animation: .default
            )
        }
    }
}
