//
//  kategoriView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI
import SQLiteData


struct kategoriView: View {
    
    @Binding var viserSheet: VisElevTilbakemleding?
    var valgtPrøveID: Prover.ID
    @Dependency(\.defaultDatabase) var database
    @State var oppgaver: [Oppgaver] = []
    @State var kategorier: [Kategorier] = []
    @State var oppgaverKategorier: [(OppgaverKategorier, Oppgaver.ID)] = []
    
    
    var body: some View {
        VStack {
            Text("Kategorier og oppgaver").font(.largeTitle)
            Grid(horizontalSpacing: 0, verticalSpacing: 0){
                GridRow{
                    Color.green.gridCellUnsizedAxes([.horizontal, .vertical])
                        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                        .border(.primary)
                    ForEach(oppgaver){oppgave in
                        Text(oppgave.navn)
                            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                            .border(.primary)
                            .background(.green)
                    }
                }
                ForEach(kategorier){ kategori in
                    GridRow() {
                        kategorierRad(kategori: kategori)
                            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                            .border(.primary)
                            .background(.orange)
                        ForEach(oppgaver){oppgave in
                            kategoriOgOppgaveCelleView(kategori: kategori,
                                                       oppgave: oppgave,
                                                       verdi: oppgaverKategorier.contains(where: {$0.0.KategoriId == kategori.id && $0.0.OppgaveId == oppgave.id}),
                                                       oppgaveKategoriId: oppgaverKategorier.first(where: {$0.0.KategoriId == kategori.id && $0.0.OppgaveId == oppgave.id})?.0.id
                            )
                        }
                    }
                }
                GridRow {
                    Button {
                        Task {
                            await leggTilKategori()
                            await hentKategorierForProve()
                        }
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .border(.primary)
                    ForEach(oppgaver){oppgave in
                        Color.green.gridCellUnsizedAxes([.horizontal, .vertical])
                            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                            .border(.primary)
                    }
                }
            }
            .task {
                await hentOppgaverKategorierForProve()
                await hentKategorierForProve()
                await hentoppgaverForProve()
                
            }
            Button("Lukk") {
                viserSheet = nil
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
    
    func hentKategorierForProve() async {
        await withErrorReporting {
            try await database.read { db in
                kategorier = try Kategorier
                    .where{ $0.proveId == self.valgtPrøveID }
                    .fetchAll(db)
            }
        }
    }
    
    func hentOppgaverKategorierForProve() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaverKategorier = try OppgaverKategorier
                    .join(Oppgaver.all) { $0.OppgaveId == $1.id }
                    .where{ $1.proveId == self.valgtPrøveID }
                    .select{($0, $1.proveId)}
                    .fetchAll(db)
            }
        }
    }
    
    func leggTilKategori() async {
        let nyKategori = Kategorier(id: UUID().uuidString, navn: "Ny ketegori", proveId: valgtPrøveID)
        await withErrorReporting {
            try await database.write { db in
                try Kategorier.insert{nyKategori}.execute(db)
            }
        }
    }

    
}

struct kategoriOgOppgaveCelleView : View {
    @Dependency(\.defaultDatabase) var database
   
    let kategori: Kategorier
    let oppgave: Oppgaver

    @State var verdi: Bool
    let oppgaveKategoriId: String?
    
    var body: some View {
        Toggle("", isOn: $verdi)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.primary)
            .onChange(of: verdi) { oldValue, newValue in
                if(newValue == true) {
                    Task {
                        await withErrorReporting {
                            try await database.write { db in
                                let midlertidigOppgaveKategori = OppgaverKategorier(id: UUID().uuidString, KategoriId: kategori.id, OppgaveId: oppgave.id)
                                try  OppgaverKategorier.insert{midlertidigOppgaveKategori}.execute(db)
                            }
                        }
                    }
                }
                else {
                    Task {
                        await withErrorReporting {
                            try await database.write { db in
                                let midlertidigOppgavveKategori = OppgaverKategorier(id: oppgaveKategoriId ?? "", KategoriId: kategori.id, OppgaveId: oppgave.id)
                                try OppgaverKategorier.delete(midlertidigOppgavveKategori).execute(db)
                            }
                        }
                    }

                }
            }
            .onAppear {
                verdi = oppgaveKategoriId != nil
            }
                    
            
    }
}
