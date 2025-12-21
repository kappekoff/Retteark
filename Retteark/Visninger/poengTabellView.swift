//
//  poengTabellView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI
import SQLiteData

struct poengTabellView: View {
    @Dependency(\.defaultDatabase) var database
    @Binding var prøve: Prover?
    @Binding var oppgaver: [Oppgaver]
    @Binding var deltakere: [Deltakere]
    @Binding var poenger: [(Poenger, Prover.ID)]
    @Binding var kategorier: [Kategorier]
    @Binding var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    
    
    
    @State var visElevTilbakemleding: VisElevTilbakemleding? = nil
    @State var oppgaveIndeks: Int? = nil
    @State var farge: Bool = false
    @State var fokus_posisjon: String = ""
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
                    maxPoengVisning(oppgave: oppgave)
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
            
            ForEach(Array(deltakere.enumerated()), id: \.element.id){ indeks, deltaker in
                deltakerRadView(deltaker: deltaker, deltakere: $deltakere, oppgaver: $oppgaver, kategorier: $kategorier, oppgaverKategorier: $oppgaverKategorier, prøve: prøve, fokus: $fokus, poenger: $poenger, indeks: indeks, visElevTilbakemleding: $visElevTilbakemleding)
                    .font(.title3).frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 50, alignment: .leading).border(.primary).background(indeks % 2 == 1 ? Color.background:.orange)
            }
        }
        .onAppear() {
            if(poenger.count > 0) {
                fokus_posisjon = poenger[0].0.id
                fokus = .poengFokus(id: fokus_posisjon)
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
    
    var deltaker: Deltakere
    var oppgaver: [Oppgaver]
    @Binding var poenger: [(Poenger, Prover.ID)]
    var indeks: Int
    
    @State var låstKarakter: Bool = true

    
    var body: some View {
        karakterView(deltaker: deltaker, oppgaver: oppgaver, poenger: $poenger, indeks: indeks,låstKarakter: $låstKarakter)
            .border(.black)
        karakterLa_sView(deltaker: deltaker, indeks: indeks, låstKarakter: $låstKarakter)
    }
}
    
            


