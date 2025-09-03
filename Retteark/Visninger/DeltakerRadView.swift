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
    var prøveID: Prover.ID
    @Binding var indeks: Int
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
                PoengView(deltakerID: deltaker.id, oppgaveID: oppgave.id, endretPoeng: $endretPoeng)
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
            sumCelle(prøveId: prøveID, deltakerId: deltaker.id, indeks: indeks, endretPoeng: $endretPoeng)
            karakterCeller(prøveID: prøveID, deltakerID: deltaker.id, indeks: indeks, endretPoeng: $endretPoeng)
            
            
        }
        .onAppear {
            indeks = indeks + 1
        }
    }
}

