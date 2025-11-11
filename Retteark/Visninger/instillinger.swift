//
//  instillinger.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 06/09/2022.
//

import SwiftUI
import SharingGRDB

struct instillinger: View {
    @Dependency(\.defaultDatabase) var database
    var valgtPrøveID: Prover.ID
    @State var prøve: Prover? = nil
    @State var oppgaver: [Oppgaver] = []
    @State var deltakere: [Deltakere] = []
    @State var kategorier: [Kategorier] = []
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @State var visEleverKarakter: Bool = false
   
    
    var body: some View {
        Text("Instillinger").font(.largeTitle)
        List(){
            Section("Kategorier"){
                ForEach(kategorier) { kategori in
                    kategorierRad(kategori: kategori)
                }
                Button {
                    Task {
                        await leggTilKategori()
                    }
                } label: {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
            }
                /*Section("Tilbakemeldinger") {
                 ForEach($prøve.tilbakemeldinger, id: \.self){ tilbakemelding in
                 HStack {
                 TextField("Tilbakemelding", text: tilbakemelding.tekst)
                 NumericTextField("Grense", number: tilbakemelding.nedreGrense, isDecimalAllowed: false).frame(width: 25, alignment: .trailing)
                 Text("%")
                 }
                 }
                 }
                 Section("Karaktergrenser") {
                 ForEach($prøve.karaktergrenser, id: \.id){ karaktergrense in
                 HStack {
                 TextField("Karaktergrense", text: karaktergrense.karakter)
                 NumericTextField("Grense", number: karaktergrense.grense, isDecimalAllowed: false).frame(width: 25, alignment: .trailing)
                 Text("%")
                 }
                 }
                 }*/
            Section("Oppgaver") {
                ForEach(oppgaver) { oppgave in
                    oppgaverRad(oppgave: oppgave)
                }
                .onDelete(perform: slettOppgaveFraListe)
                Button {
                    let nyOppgave = Oppgaver(id: UUID().uuidString, navn: "", proveId: valgtPrøveID, maksPoeng: 2)
                    Task {
                        await withErrorReporting {
                            try await database.write { db in
                                try Oppgaver.insert{nyOppgave}.execute(db)
                            }
                        }
                    }
                }
                label: {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
            }
            Section("Deltakere") {
                ForEach(deltakere) { deltaker in
                    deltakerRad(deltaker: deltaker)
                }
            }
            Section("Om prøven"){
                Toggle("Vis elever karakter", isOn: $visEleverKarakter)
                    .onChange(of: visEleverKarakter) { gammelverdi, nyVerdi in
                        Task {
                            await withErrorReporting {
                                try await database.write { db in
                                    if var prøve = self.prøve {
                                        prøve.visEleverKarakter = nyVerdi
                                        try Prover.update(prøve).execute(db)
                                    }
                                }
                            }
                        }
                    }
            }
        }
        .task {
            await hentPrøve()
            await hentoppgaverForProve()
            await hentDeltakereForProve()
            await hentKategorierForProve()
            visEleverKarakter = prøve?.visEleverKarakter ?? false
        }
        Button("Lukk") {
            visElevTilbakemleding = nil
        }
    }
    
    func hentPrøve() async {
        await withErrorReporting {
            try await database.read { db in
                prøve = try Prover
                    .where { $0.id == self.valgtPrøveID}
                    .fetchOne(db)
            }
        }
    }
    
    func hentoppgaverForProve() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaver = try Oppgaver
                    .where{ $0.proveId == self.valgtPrøveID }
                    .fetchAll(db)
            }
        }
    }
    
    func hentDeltakereForProve() async {
        await withErrorReporting {
            try await database.read { db in
                deltakere = try Deltakere
                    .where{ $0.proveId == self.valgtPrøveID }
                    .fetchAll(db)
            }
        }
    }
    
    func hentKategorierForProve() async {
        await withErrorReporting {
            try await database.read { db in
                kategorier = try Kategorier
                    .where{ $0.proveId == self.valgtPrøveID }
                    .fetchAll(db)
            }
        }
    }
    
    func leggTilKategori() async {
        let nyKategori = Kategorier(id: UUID().uuidString, navn: "", proveId: valgtPrøveID)
        await withErrorReporting {
            try await database.write { db in
                try Kategorier.insert{nyKategori}.execute(db)
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


struct oppgaverRad: View {
    @Dependency(\.defaultDatabase) var database
    var oppgave: Oppgaver
    @State var oppgaveNavn = ""
    @State var oppgaveMaksPoeng: Double? = nil
    
    var body: some View {
        HStack {
            TextField("Oppgavenavn", text: $oppgaveNavn)
            Spacer()
            NumericTextField("Makspoeng", number: $oppgaveMaksPoeng, isDecimalAllowed: true)
        }
        .onAppear {
            oppgaveNavn = oppgave.navn
            oppgaveMaksPoeng = oppgave.maksPoeng ?? nil
        }
        .onChange(of: [oppgaveNavn, String(oppgaveMaksPoeng ?? 0)]) {
            Task {
                await withErrorReporting {
                    try await database.write { db in
                        let midlertidigOppgave = Oppgaver(id: oppgave.id, navn: oppgaveNavn, proveId: oppgave.proveId, maksPoeng: oppgaveMaksPoeng ?? 2)
                        try Oppgaver.update(midlertidigOppgave)
                            .execute(db)
                    }
                }
            }
        }
            
    }
}

struct deltakerRad: View {
    @Dependency(\.defaultDatabase) var database
    var deltaker: Deltakere
    
    @State var deltakerNavn: String = ""
    
    var body: some View {
        TextField("Deltakernavn", text: $deltakerNavn)
            .onAppear {
                deltakerNavn = deltaker.navn
            }
            .onChange(of: deltakerNavn) {
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            let midlertidigDeltaker = Deltakere(id: deltaker.id, navn: deltakerNavn, proveId: deltaker.proveId, låstKarakter: deltaker.låstKarakter, karakter: deltaker.karakter, framovermelding: "")
                            try Deltakere.update(midlertidigDeltaker)
                                .execute(db)
                        }
                    }
                }
            }
                
    }
}

struct kategorierRad: View {
    @Dependency(\.defaultDatabase) var database
    var kategori: Kategorier
    
    @State var kategoriNavn: String = ""
    
    var body: some View {
        TextField("Kategorinavn", text: $kategoriNavn)
            .onAppear {
                kategoriNavn = kategori.navn
            }
            .onChange(of: kategoriNavn) {
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            let midlertidigKategori = Kategorier(id: kategori.id, navn: kategoriNavn, proveId: kategori.proveId)
                            try Kategorier.update(midlertidigKategori)
                                .execute(db)
                        }
                    }
                }
            }
    }
}


