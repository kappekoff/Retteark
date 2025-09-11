//
//  kategoriView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI
import SharingGRDB


struct kategoriView: View {
    @Environment(Klasseoversikt.self) var klasseoversikt
    
    @Bindable var prøve: Prøve
    
    @Binding var viserSheet: VisElevTilbakemleding?
    var valgtPrøveID: Prover.ID
    @Dependency(\.defaultDatabase) var database
    @FetchAll var oppgaver: [Oppgaver] = []
    @FetchAll var kategorier: [Kategorier] = []
    @FetchAll var oppgaverKategorier: [OppgaverKategorier] = []
    
    
    var body: some View {
        VStack {
            Text("Kategorier og oppgaver").font(.largeTitle)
            Grid(horizontalSpacing: 0, verticalSpacing: 0){
                GridRow{
                    Color.green.gridCellUnsizedAxes([.horizontal, .vertical]).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary)
                    ForEach(oppgaver){oppgave in
                        Text(oppgave.navn)
                    }.frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(.green)
                }
                ForEach(kategorier){ kategori in
                    GridRow() {
                        Text(kategori.navn).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(.orange)
                        ForEach(prøve.oppgaver){oppgave in
                            
                                        
                        }
                    }
                }
            }
            Button("Lukk") {
                klasseoversikt.lagreKlasser()
                viserSheet = nil
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
    
    func hentKategorierForProve() async {
        await withErrorReporting {
            try await $kategorier.load(
                Kategorier
                    .where{ $0.proveId == self.valgtPrøveID },
                animation: .default
            )
        }
    }
    
    func hentOppgaverKategorierForProve() async {
        await withErrorReporting {
            try await $oppgaverKategorier.load(
                OppgaverKategorier
                    .joining(required: OppgaverKategorier.belongsTo(Oppgaver.self, key: "OppgaveId"))
                    .where{ $0.proveId == self.valgtPrøveID }
                    ,
                animation: .default
            )
        }
    }
}

struct kategoriOgOppgaveCelleView : View {
    let kategori: Kategorier
    let oppgave: Oppgaver
    
    @State var verdi: Bool = false
    
    var body: some View {
        Toggle("", isOn: $verdi)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.primary)
            
    }
}
