//
//  redigerPrøve.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/03/2023.
//

import SwiftUI

struct redigerPr_ve: View {
    var prøveId: Prøve.ID
    var klasseId: Klasse.ID
    @ObservedObject var klasseoversikt: Klasseoversikt
    @Binding var visKlassevisningSheet:VisKlassevisningSheet?
    var klasseIndex: Int? {
        klasseoversikt.klasseinformasjon.klasser.firstIndex(where: {$0.id==klasseId})
    }
    var prøveIndex: Int? {
        if let klasseIndex = klasseIndex {
            return klasseoversikt.klasseinformasjon.klasser[klasseIndex].prøver.firstIndex(where: {$0.id==prøveId})
        }
        else {
            return nil
        }
    }
    
    var body: some View {
        if let klasseIndex = klasseIndex, let prøveIndex = prøveIndex {
            NavigationStack {
                Section("Om prøven"){
                    TextInputField(title: "Prøvenavn", text: $klasseoversikt.klasseinformasjon.klasser[klasseIndex].prøver[prøveIndex].navn)
                    Toggle("Vis karakter til elever", isOn: $klasseoversikt.klasseinformasjon.klasser[klasseIndex].prøver[prøveIndex].visEleverKarakter)
                }
                Section("Oppgaver") {
                    List() {
                        ForEach($klasseoversikt.klasseinformasjon.klasser[klasseIndex].prøver[prøveIndex].oppgaver) { oppgave in
                            HStack {
                                TextField("Oppgavenavn", text: oppgave.navn)
                                Spacer()
                                NumericTextField("Makspoeng", number: oppgave.maksPoeng, isDecimalAllowed: true)
                            }
                        }
                        .onDelete(perform: slettOppgaveFraListe)
                        Button {
                            klasseoversikt.klasseinformasjon.klasser[klasseIndex].prøver[prøveIndex].oppgaver.append(Oppgave(navn: "", maksPoeng: 1))
                        } label: {
                            Image(systemName: "plus.circle").foregroundColor(.green)
                        }
                    }
                }
                HStack {
                    Button("Lukk") {
                        visKlassevisningSheet = nil
                    }
                }.navigationTitle("Legg til Ny prøve")
            }
        }
    }
    
    func slettOppgaveFraListe(at offsets: IndexSet){
        if let klasseIndex = klasseIndex, let prøveIndex = prøveIndex {
            klasseoversikt.klasseinformasjon.klasser[klasseIndex].prøver[prøveIndex].oppgaver.remove(atOffsets: offsets)
        }
    }
        
}
