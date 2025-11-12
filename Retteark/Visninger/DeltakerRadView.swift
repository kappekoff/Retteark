//
//  DeltakerRadView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2025.
//

import SwiftUI

struct deltakerRadView: View {
    var deltaker: Deltakere
    var oppgaver: [Oppgaver]
    var kategorier: [Kategorier]
    var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    var prøve: Prover?
    @Binding var poenger: [(Poenger, Prover.ID)]
    var indeks: Int
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @State var endretPoeng: Int = 0
    
    var body: some View {
        GridRow(){
            Button(action: {
                visElevTilbakemleding = .valgtElev(deltaker:  deltaker)
            }, label: {
                Text(deltaker.navn)
            })
            ForEach(oppgaver){ oppgave in
                PoengView(deltaker: deltaker, oppgave: oppgave, poenger: $poenger , endretPoeng: $endretPoeng)
                /*.focused($fokus, equals: .poengFokus(id: $prøve.poeng[elevIndeks][oppgaveIndeks].id))
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
            sumCelle(oppgaver: oppgaver, poenger: $poenger, deltaker: deltaker, indeks: indeks, endretPoeng: $endretPoeng)
            karakterCeller(deltaker: deltaker, oppgaver: oppgaver, poenger: $poenger, indeks: indeks, endretPoeng: $endretPoeng)
                .fullScreenCover(item: $visElevTilbakemleding, onDismiss: { visElevTilbakemleding = nil }) { visElevTilbakemleding in
                    switch visElevTilbakemleding{
                    case .valgtElev(let valgtDeltaker):
                        if let prøve = prøve {
                            elevTilbakemeldingVisning(visElevTilbakemleding: $visElevTilbakemleding, lagerPDF: false, deltaker: valgtDeltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, poenger: $poenger, oppgaverKategorier: oppgaverKategorier)
                        }
                        else {
                            Text("Fant ikke prøve")
                        }
                        
                    default:
                        Text("Du skal aldri komme hit")
                    }
                }
            
        }
    }
}

