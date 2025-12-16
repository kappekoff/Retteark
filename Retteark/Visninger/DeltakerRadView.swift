//
//  DeltakerRadView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2025.
//

import SwiftUI

struct deltakerRadView: View {
    let deltaker: Deltakere
    @Binding var deltakere: [Deltakere]
    @Binding var oppgaver: [Oppgaver]
    @Binding var kategorier: [Kategorier]
    @Binding var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    var prøve: Prover?
    @FocusState.Binding var fokus: Fokus?
    @Binding var poenger: [(Poenger, Prover.ID)]
    var indeks: Int
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    var body: some View {
        GridRow(){
            Button(action: {
                visElevTilbakemleding = .valgtElev(deltaker:  deltaker)
            }, label: {
                Text(deltaker.navn)
            })
            ForEach(oppgaver.enumerated(), id: \.element.id){ oppgaveIndeks, oppgave in
                PoengView(deltaker: deltaker, oppgave: oppgave, poenger: $poenger)
                    .focused($fokus, equals: .poengFokus(id: poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0.id ?? "fant ikke poeng for denne cellen"))
                    .onSubmit {
                        if(poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0.poeng == "") {
                            let poengIndeks = poenger.firstIndex(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})
                            guard let poengIndeks = poengIndeks else {
                                return
                            }
                            poenger[poengIndeks].0.poeng = oppgave.maksPoeng != nil ? String(oppgave.maksPoeng!) : ""
                        }
                        let nesteOppgave:Oppgaver = oppgaveIndeks >= (oppgaver.count - 1) ? oppgaver[0] : oppgaver[oppgaveIndeks+1]
                        let nestePoenger:Poenger? = poenger.first(where: {$0.0.oppgaveId == nesteOppgave.id && $0.0.deltakerId == deltaker.id})?.0
                        let fokus_posisjon: Fokus = .poengFokus(id: nestePoenger?.id ?? "")
                         fokus = fokus_posisjon
                    }
            }
            sumCelle(oppgaver: oppgaver, poenger: $poenger, deltaker: deltaker, indeks: indeks)
            karakterCeller(deltaker: deltaker, oppgaver: oppgaver, poenger: $poenger, indeks: indeks)
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

