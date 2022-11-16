//
//  instillinger.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 06/09/2022.
//

import SwiftUI

struct instillinger: View {
    @ObservedObject var prøve: Prøve
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    
    var body: some View {
            List(){
                Section("Kategorier"){
                    ForEach($prøve.kategorier){ kategori in
                        TextField("kategori.navn", text: kategori.navn)
                    }
                    Button {
                        prøve.leggTilKategori()
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
                Section("Tilbakemeldinger") {
                    ForEach($prøve.tilbakemeldinger, id: \.self){ tilbakemelding in
                        HStack {
                            TextField("Tilbakemelding", text: tilbakemelding.tekst)
                            NumericTextField("Grense", number: tilbakemelding.nedreGrense, isDecimalAllowed: false).frame(width: 25, alignment: .trailing)
                            Text("%")
                        }
                    }
                }
                Section("Oppgaver") {
                    ForEach($prøve.oppgaver) { oppgave in
                        HStack {
                            TextField("Oppgavenavn", text: oppgave.navn)
                            Spacer()
                            NumericTextField("Makspoeng", number: oppgave.maksPoeng, isDecimalAllowed: true)
                        }
                    }
                    .onDelete(perform: slettOppgaveFraListe)
                    Button {
                        prøve.oppgaver.append(Oppgave(navn: "", maksPoeng: 1))
                        for i in 0..<prøve.elever.count {
                            prøve.poeng[i].append(Poeng(id: [i, prøve.oppgaver.count-1], poeng: "", elevId: prøve.elever[i].id, OppgaveId: prøve.oppgaver[prøve.oppgaver.count-1].id))
                        }
                    }
                    label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
                Section("Om prøven"){
                    Toggle("Vis elever karakter", isOn: $prøve.visEleverKarakter)
                }
        }
        
        Button("Lukk") {
            visElevTilbakemleding = nil
        }
    }
    func slettOppgaveFraListe(at offsets: IndexSet){
        prøve.oppgaver.remove(atOffsets: offsets)
    }
}

