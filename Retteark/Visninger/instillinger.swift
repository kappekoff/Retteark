//
//  instillinger.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 06/09/2022.
//

import SwiftUI
import SharingGRDB

struct instillinger: View {
    @Environment(Klasseoversikt.self) var klasseoversikt
    @Dependency(\.defaultDatabase) var database
    var valgtPrøveID: Prover.ID
    @State var prøve: Prover? = nil
    @FetchAll var oppgaver: [Oppgaver] = []
    @FetchAll var deltakere: [Deltakere] = []
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @State var visEleverKarakter: Bool = false
   
    
    var body: some View {
            Text("Instillinger").font(.largeTitle)
            List(){
                /*Section("Kategorier"){
                    ForEach($prøve.kategorier){ kategori in
                        TextField("kategori.navn", text: kategori.navn)
                    }
                    Button {
                        prøve.leggTilKategori()
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
                Section("Tilbakemeldinger") {
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
                visEleverKarakter = prøve?.visEleverKarakter ?? false
            }

        
        Button("Lukk") {
            klasseoversikt.lagreKlasser()
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
            try await $oppgaver.load(
                Oppgaver
                    .where{ $0.proveId == self.valgtPrøveID },
                animation: .default
            )
        }
    }
    
    func hentDeltakereForProve() async {
        await withErrorReporting {
            try await $deltakere.load(
                Deltakere
                    .where{ $0.proveId == self.valgtPrøveID },
                animation: .default
            )
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
    }
}

struct deltakerRad: View {
    var deltaker: Deltakere
    
    @State var deltakerNavn: String = ""
    
    var body: some View {
        TextField("Deltakernavn", text: $deltakerNavn)
            .onAppear {
                deltakerNavn = deltaker.navn
            }
    }
    
}
