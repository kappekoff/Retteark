//
//  leggTilNyPrøveVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/09/2022.
//

import SwiftUI

struct leggTilNyPr_veVisning: View {
    var klasseoversikt: Klasseoversikt
    var KlasseID: String
    @Binding var visElevTilbakemelding: VisElevTilbakemleding?
    
    @State var prøveNavn: String = ""
    @State var oppgaver: [Oppgave] = [];
    @State var visEleverKarakter = true;
    
    
    
    
    var body: some View {
        NavigationStack {
            Section("Om prøven"){
                TextInputField(title: "Prøvenavn", text: $prøveNavn)
                Toggle("Vis karakter til elever", isOn: $visEleverKarakter)
            }
            Section("Oppgaver") {
                List() {
                    ForEach($oppgaver) { oppgave in
                        HStack {
                            TextField("Oppgavenavn", text: oppgave.navn)
                            Spacer()
                            NumericTextField("Makspoeng", number: oppgave.maksPoeng, isDecimalAllowed: true)
                            
                        }
                        
                        
                    }
                    .onDelete(perform: slettOppgaveFraListe)
                    Button {
                        oppgaver.append(Oppgave(id: oppgaver.count+1, navn: "", maksPoeng: 1))
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
            }
           
            Button("Legg til") {
                let klasseIndex = klasseoversikt.klasser.firstIndex(where: {$0.id == KlasseID})
                if (klasseIndex != nil) {
                    klasseoversikt.klasser[klasseIndex!].prøver.append(Prøve(navn: prøveNavn, elever: klasseoversikt.klasser[klasseIndex!].elever, oppgaver: oppgaver, kategorier: [], visEleverKarakter: visEleverKarakter))
                    klasseoversikt.lagreKlasser()
                    visElevTilbakemelding = nil
                }
                else {
                    visElevTilbakemelding = nil
                }
                
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Legg til Ny prøve")
    }
    func slettOppgaveFraListe(at offsets: IndexSet){
        oppgaver.remove(atOffsets: offsets)    }
}

