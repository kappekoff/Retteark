//
//  leggTilNyPrøveVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/09/2022.
//

import SwiftUI

struct leggTilNyPr_veVisning: View {
    @Environment(Klasseoversikt.self) var klasseoversikt
    var KlasseID: String
    @Binding var visKlassevisningSheet: VisKlassevisningSheet?
    @State var prøveNavn: String = ""
    @State var oppgaver: [Oppgave] = [];
    @State var visEleverKarakter = true;
    @State var nyeOppgaver: String = "";
    @State var maksPoeng: Float? = nil
    
    
    
    
    var body: some View {
        @Bindable var klasseoversikt = klasseoversikt
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
                    NumericTextField("Makspoeng", number: $maksPoeng, isDecimalAllowed: true)
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
            HStack {
                Button("Avbryt") {
                    visKlassevisningSheet = nil
                }
                Button("Legg til") {
                    let klasseIndex = klasseoversikt.klasseinformasjon.klasser.firstIndex(where: {$0.id == KlasseID})
                    if (klasseIndex != nil) {
                        klasseoversikt.klasseinformasjon.klasser[klasseIndex!].prøver.append(Prøve(navn: prøveNavn, elever: klasseoversikt.klasseinformasjon.klasser[klasseIndex!].elever.sorted(by: {$0.navn.lowercased() < $1.navn.lowercased()}), oppgaver: oppgaver, kategorier: [], visEleverKarakter: visEleverKarakter))
                        klasseoversikt.lagreKlasser()
                        visKlassevisningSheet = nil
                    }
                    else {
                        visKlassevisningSheet = nil
                    }
                    
                }
            }
        }
        .navigationTitle("Legg til ny prøve")
    }
    
    func slettOppgaveFraListe(at offsets: IndexSet){
        oppgaver.remove(atOffsets: offsets)
    }
    
    func leggTilNyeOppgaver() {
        let listeMedNyeOppgaver:[Oppgave] = oppgaverFraListeMedOppgavenavn(listeMedOppgavenavn: lagOppgaver(input: nyeOppgaver), maksPoeng: maksPoeng)
        oppgaver.append(contentsOf: listeMedNyeOppgaver)
        nyeOppgaver = ""
    }
}
