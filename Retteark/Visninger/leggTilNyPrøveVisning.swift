//
//  leggTilNyPrøveVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/09/2022.
//

import SwiftUI

struct leggTilNyPr_veVisning: View {
    @ObservedObject var klasseoversikt: Klasseoversikt
    var KlasseID: String
    @Binding var visLeggTilPrøve: Bool
    @State var prøveNavn: String = ""
    @State var oppgaver: [Oppgave] = [];
    @State var visEleverKarakter = true;
    @State var nyeOppgaver: String = "";
    
    
    
    
    var body: some View {
        NavigationStack {
            Text("Legg til ny prøve").font(.largeTitle)
            Section("Om prøven"){
                TextInputField(title: "Prøvenavn", text: $prøveNavn)
                Toggle("Vis karakter til elever", isOn: $visEleverKarakter)
            }
            Section("Oppgaver") {
                HStack {
                    TextField("Oppgavenavn: 1-15, 1.a-d", text: $nyeOppgaver)
                        .onSubmit {
                            leggTilNyeOppgaver()
                        }
                    Button("Legg til") {
                        leggTilNyeOppgaver()
                    }
                    
                }
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
                        oppgaver.append(Oppgave(navn: "", maksPoeng: 1))
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
                    visLeggTilPrøve = false
                }
                else {
                    visLeggTilPrøve = false
                }
                
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Legg til Ny prøve")
    }
    
    func slettOppgaveFraListe(at offsets: IndexSet){
        oppgaver.remove(atOffsets: offsets)
    }
    
    func leggTilNyeOppgaver() {
        let listeMedNyeOppgaver:[Oppgave] = oppgaverFraListeMedOppgavenavn(listeMedOppgavenavn: lagOppgaver(input: nyeOppgaver))
        oppgaver.append(contentsOf: listeMedNyeOppgaver)
        nyeOppgaver = ""
    }
}
