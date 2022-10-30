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
                Image(systemName: "light.max")
                ForEach($prøve.oppgaver){oppgave in
                    PoengView(poeng: oppgave.maksPoeng)
                        /*onSubmit({
                            if let oppgaveIndeks = prøve.oppgave(elevIndeks: elevIndeks, oppgaveId: oppgave.id) {
                                let endringsfaktor = (prøve.oppgaver[oppgaveIndeks].maksPoeng ?? 0) / prøve.oppgaver[oppgaveIndeks].maksPoengGammelVerdi
                                prøve.oppgaver[oppgaveIndeks].maksPoengGammelVerdi = prøve.oppgaver[oppgaveIndeks].maksPoeng ?? 0
                                
                                prøve.endrePoengAlleElever(oppgaveIndeks: oppgaveIndeks, endringsfaktor: endringsfaktor)
                            }
                        })*/
                }
                Text(String(prøve.oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)))
                Text("6")
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            }
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).font(.title).border(.primary).fontWeight(.bold).background(.gray)
            ForEach(prøve.elever){elev in
                if let elevIndeks = prøve.poengRad(elevId: elev.id) {
                    GridRow(){
                        Button(elev.navn) {
                            visElevTilbakemleding = .valgtElev(elev: elev)
                        }
                        .sheet(item: $visElevTilbakemleding, onDismiss: { visElevTilbakemleding = nil }) { visElevTilbakemleding in
                            switch visElevTilbakemleding{
                            case .valgtElev(let elev):
                                elevTilbakemeldingVisning(elev: elev, visElevTilbakemleding: $visElevTilbakemleding, prøve: prøve)
                            default:
                                Text("Du skal aldri komme hit")
                            }
                        }
                        
                        ForEach(prøve.oppgaver){ oppgave in
                            if let oppgaveIndeks = prøve.oppgave(elevIndeks: elevIndeks, oppgaveId: oppgave.id) {
                                PoengView(poeng: $prøve.poeng[elevIndeks][oppgaveIndeks].poeng)
                                    .background(elevIndeks % 2 != 0 ? Color(UIColor.systemBackground):.orange)
                            }
                            
                        }
                        sumCelle(poeng: $prøve.poeng[elevIndeks], farge: elevIndeks % 2 != 0)
                        karakterView(poeng: $prøve.poeng[elevIndeks], farge: elevIndeks % 2 != 0, maxPoeng: prøve.oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +), elev: $prøve.elever[elevIndeks])
                            .background(elevIndeks % 2 != 0 ? Color(UIColor.systemBackground):.orange)
                        Button(action: {
                            prøve.elever[elevIndeks].låstKarakter.toggle()
                        }, label: {
                            Image(systemName: prøve.elever[elevIndeks].låstKarakter ? "lock.open.fill" : "lock.fill")
                        })
                    }
                    .font(.title3).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(elevIndeks % 2 != 0 ? Color(UIColor.systemBackground):.orange)
                }
            }
        }
    }
}



