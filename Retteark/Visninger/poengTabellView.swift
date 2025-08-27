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
    @State var elevIndeks: Int? = nil
    @State var oppgaveIndeks: Int? = nil
    @State var farge: Bool = false
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
                GridRow(){
                    Button(action: {
                        visElevTilbakemleding = .valgtElev(deltaker:  deltaker)
                    }, label: {
                        Text(deltaker.navn)
                    })
                    ForEach(oppgaver){ oppgave in
                        /*PoengView(poeng:)
                            .focused($fokus, equals: .poengFokus(id: $prøve.poeng[elevIndeks][oppgaveIndeks].id))
                            .onSubmit {
                                if(prøve.poeng[elevIndeks][oppgaveIndeks].poeng == "") {
                                    prøve.poeng[elevIndeks][oppgaveIndeks].poeng = String((oppgave.maksPoeng!))
                                    var fokus_posisjon = [elevIndeks, oppgaveIndeks+1]
                                    if(fokus?.get()[1] ?? 0 >= prøve.oppgaver.count - 1) {
                                        fokus_posisjon = [(fokus?.get()[0] ?? 0) + 1, 0]
                                    }
                                    fokus = .poengFokus(id: fokus_posisjon)
                                }
                            }*/
                    }
                    sumCelle(prøveId: prøveID, deltakerId: deltaker.id)
                    //karakterView(prøve: prøve!, elevIndeks: elevIndeks!)
                    /*Button(action: {
                        deltaker.låstKarakter.toggle()
                    }, label: {
                        Image(systemName: deltaker.låstKarakter ? "lock.open.fill" : "lock.fill")
                    })*/
                    .fullScreenCover(item: $visElevTilbakemleding, onDismiss: { visElevTilbakemleding = nil }) { visElevTilbakemleding in
                        switch visElevTilbakemleding{
                        case .valgtElev(let elev):
                            Text("skal fikse senere")//elevTilbakemeldingVisning(deltaker: deltaker, visElevTilbakemleding: $visElevTilbakemleding)
                        default:
                            Text("Du skal aldri komme hit")
                        }
                    }
                }
                .font(.title3).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background((elevIndeks ?? 0) % 2 == 1 ? Color.background:.orange)
             }
        }.task {
            fokus_posisjon = [0, 0]
            fokus = .poengFokus(id: fokus_posisjon)
            await hentPrøve()
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
            


