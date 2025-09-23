//
//  poengTabellView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI
import SharingGRDB

struct poengTabellView: View {
    @Dependency(\.defaultDatabase) var database
    var prøveID: Prover.ID
    @State var prøve: Prover? = nil
    @State var oppgaver: [Oppgaver] = []
    @State var deltakere: [Deltakere] = []

    
    @State var visElevTilbakemleding: VisElevTilbakemleding? = nil
    @State var oppgaveIndeks: Int? = nil
    @State var farge: Bool = false
    @State var indeks: Int = 0
    @State var fokus_posisjon: [Int] = [0, 0]
    @FocusState var fokus: Fokus?

    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0){
            GridRow{
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                ForEach(oppgaver){oppgave in
                    oppgaveNavnCelle(oppgave: oppgave)
                }
                Image(systemName: "sum")
                Image(systemName: "graduationcap.fill")
                Image(systemName: "lock.fill")
            }
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).font(.title).fontWeight(.bold).border(.primary).background(.green).multilineTextAlignment(.center)
            GridRow{
                Image(systemName: "number")
                ForEach($oppgaver){oppgave in
                    maxPoengVisning(poeng: oppgave.maksPoeng)
                        .onChange(of: oppgave.maksPoeng.wrappedValue) { gammelVerdi, nyVerdi in
                            //må endre her seneere
                            print("Endret maks poeng fra \(String(describing: gammelVerdi)) til \(String(describing: nyVerdi))")
                        }
                }
                Text(String(oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)))
                Text("6")
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50).font(.title).border(.primary).fontWeight(.bold).background(.gray)
            
            ForEach(deltakere){ deltaker in
                deltakerRadView(deltaker: deltaker, oppgaver: oppgaver, prøveID: prøveID, indeks: $indeks, visElevTilbakemleding: $visElevTilbakemleding)
                    .fullScreenCover(item: $visElevTilbakemleding, onDismiss: { visElevTilbakemleding = nil }) { visElevTilbakemleding in
                        switch visElevTilbakemleding{
                        case .valgtElev(let elev):
                            elevTilbakemeldingVisning(visElevTilbakemleding: $visElevTilbakemleding, deltakerId: deltaker.id, prøveId: prøveID)
                        default:
                            Text("Du skal aldri komme hit")
                        }
                    }
                    .font(.title3).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(indeks % 2 == 1 ? Color.background:.orange)
                
             }
        }
        .onAppear() {
            fokus_posisjon = [0, 0]
            fokus = .poengFokus(id: fokus_posisjon)
            Task {
                await hentPrøve()
                await hentOppgaver()
                await hentDeltakere()
            }
        }
        .onChange(of: prøveID)  {
            fokus_posisjon = [0, 0]
            fokus = .poengFokus(id: fokus_posisjon)
            Task {
                await hentPrøve()
                await hentOppgaver()
                await hentDeltakere()
            }
            
        }
    }
    
    func hentPrøve() async {
        await withErrorReporting {
            try await database.read { db in
                prøve = try Prover
                    .where { $0.id == self.prøveID}
                    .fetchOne(db)
            }
        }
    }
    
    func hentOppgaver() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaver = try Oppgaver
                    .where { $0.proveId == self.prøveID}
                    .fetchAll(db)
            }
        }
    }
    
    func hentDeltakere() async {
        await withErrorReporting {
            try await database.read { db in
                deltakere = try Deltakere
                    .where { $0.proveId == self.prøveID}
                    .fetchAll(db)
            }
        }
    }    
}

struct oppgaveNavnCelle: View {
    var oppgave: Oppgaver
    @State var oppgaveNavn = ""
    
    var body : some View {
        TextField("Oppgave navn", text: $oppgaveNavn)
            .onAppear {
                oppgaveNavn = oppgave.navn
            }
    }
}

struct karakterCeller: View {
    
    var prøveID: Prover.ID
    var deltakerID: Deltakere.ID
    var indeks: Int
    
    @State var låstKarakter: Bool = true
    @Binding var endretPoeng: Int

    
    var body: some View {
        karakterView(prøveId: prøveID, deltakerId: deltakerID, indeks: indeks,låstKarakter: $låstKarakter, endretPoeng: $endretPoeng)
        karakterLa_sView(deltakerID: deltakerID, indeks: indeks, låstKarakter: $låstKarakter)
    }
}
    
            


