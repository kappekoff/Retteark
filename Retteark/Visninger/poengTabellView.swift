//
//  poengTabellView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI

struct poengTabellView: View {
    
    @ObservedObject var prøve: Prøve
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
                ForEach($prøve.oppgaver){oppgave in
                    TextField("Oppgave navn", text: oppgave.navn)
                }
                Image(systemName: "sum")
                Image(systemName: "graduationcap.fill")
                Image(systemName: "lock.fill")
            }
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).font(.title).fontWeight(.bold).border(.primary).background(.green).multilineTextAlignment(.center)
            GridRow{
                Image(systemName: "number")
                ForEach($prøve.oppgaver){oppgave in
                    maxPoengVisning(poeng: oppgave.maksPoeng)
                    .onSubmit{
                        prøve.endrePoengAlleElever(oppgaveId: oppgave.id)
                    }
                }
                Text(String(prøve.oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)))
                Text("6")
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            }
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).font(.title).border(.primary).fontWeight(.bold).background(.gray)
            ForEach(prøve.elever){elev in
                if let elevIndeks = prøve.poengRad(elevId: elev.id){
                    GridRow(){
                        Button(action: {
                            visElevTilbakemleding = .valgtElev(elev:  prøve.elever.first(where: { elevv in
                              return elevv.id == prøve.poeng[elevIndeks][optional: 0]?.elevId
                            })!)
                        }, label: {
                            Text( prøve.elever.first(where: { elevv in
                              return elevv.id == prøve.poeng[elevIndeks][optional: 0]?.elevId
                            })!.navn)
                        })
                        
                        ForEach(prøve.oppgaver){ oppgave in
                            if let oppgaveIndeks = prøve.oppgave(elevIndeks: elevIndeks, oppgaveId: oppgave.id) {
                                PoengView(poeng: $prøve.poeng[elevIndeks][oppgaveIndeks])
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
                                        
                                    }
                            }
                            
                        }
                        sumCelle(prøve: prøve, elevIndeks: elevIndeks)
                        karakterView(prøve: prøve, elevIndeks: elevIndeks)
                        Button(action: {
                            for i in 0..<prøve.elever.count {
                                if prøve.elever[i].id == prøve.poeng[elevIndeks][optional: 0]?.elevId {
                                    prøve.elever[i].låstKarakter = !prøve.elever[i].låstKarakter
                                }
                            }
                        }, label: {
                            Image(systemName: prøve.elever.first(where: { elevv in
                                return elevv.id == prøve.poeng[elevIndeks][optional: 0]?.elevId
                              })!.låstKarakter ? "lock.open.fill" : "lock.fill")
                        })
                        .fullScreenCover(item: $visElevTilbakemleding, onDismiss: { visElevTilbakemleding = nil }) { visElevTilbakemleding in
                            switch visElevTilbakemleding{
                            case .valgtElev(let elev):
                                elevTilbakemeldingVisning(elev: elev, visElevTilbakemleding: $visElevTilbakemleding, prøve: prøve)
                            default:
                                Text("Du skal aldri komme hit")
                            }
                        }
                        
                    }
                    .font(.title3).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(elevIndeks % 2 == 1 ? Color.background:.orange)
                }
            }
        }.onAppear {
            if (prøve.elever.count > 0 && prøve.oppgaver.count > 0) {
                if let elevIndeks = prøve.poengRad(elevId: prøve.elever[0].id){
                    if let oppgaveIndeks = prøve.oppgave(elevIndeks: elevIndeks, oppgaveId: prøve.oppgaver[0].id) {
                        fokus_posisjon = [elevIndeks, oppgaveIndeks]
                        fokus = .poengFokus(id: fokus_posisjon)
                    }
                }
            }
        }
    }
}



