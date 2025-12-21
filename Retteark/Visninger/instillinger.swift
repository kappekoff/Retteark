//
//  instillinger.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 06/09/2022.
//

import SwiftUI
import SQLiteData

struct instillinger: View {
    @Dependency(\.defaultDatabase) var database
    @Binding var prøve: Prover?
    @Binding var oppgaver: [Oppgaver]
    @Binding var deltakere: [Deltakere]
    @Binding var kategorier: [Kategorier]
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @State var visEleverKarakter: Bool = false
   
    
    var body: some View {
        Text("Instillinger").font(.largeTitle)
        List(){
            Section("Kategorier"){
                ForEach($kategorier) { kategori in
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
                ForEach($oppgaver) { oppgave in
                    oppgaverRad(oppgave: oppgave)
                }
                .onDelete(perform: slettOppgaveFraListe)
                Button {
                    let nyOppgave = Oppgaver(id: UUID().uuidString, navn: "", proveId: prøve?.id ?? "", maksPoeng: 2)
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
                ForEach($deltakere) { deltaker in
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
            visEleverKarakter = prøve?.visEleverKarakter ?? false
        }
        Button("Lukk") {
            visElevTilbakemleding = nil
        }
    }
    
    func leggTilKategori() async {
        let nyKategori = Kategorier(id: UUID().uuidString, navn: "", proveId: prøve?.id ?? "")
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
    @Binding var oppgave: Oppgaver

    
    var body: some View {
        HStack {
            TextField("Oppgavenavn", text: $oppgave.navn)
            Spacer()
            NumericTextField("Makspoeng", number: $oppgave.maksPoeng, isDecimalAllowed: true)
        }
        .onChange(of: oppgave) {
            let oppgaveSomSkalLagres = oppgave
            Task {
                await withErrorReporting {
                    try await database.write { db in
                        try Oppgaver.update(oppgaveSomSkalLagres)
                            .execute(db)
                    }
                }
            }
        }
            
    }
}

struct deltakerRad: View {
    @Dependency(\.defaultDatabase) var database
    @Binding var deltaker: Deltakere
        
    var body: some View {
        TextField("Deltakernavn", text: $deltaker.navn)
            .onChange(of: deltaker) {
                let midlertidigDeltaker = deltaker
                Task {
                    await withErrorReporting {
                        try await database.write { db in
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
    @Binding var kategori: Kategorier
    
    
    var body: some View {
        TextField("Kategorinavn", text: $kategori.navn)
            .onChange(of: kategori) {
                let midlertidigKategori = kategori
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            try Kategorier.update(midlertidigKategori)
                                .execute(db)
                        }
                    }
                }
            }
    }
}


