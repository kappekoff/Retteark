//
//  instillinger.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 06/09/2022.
//

import SwiftUI

struct instillinger: View {
    @ObservedObject var prøve: Prøve
    
    var body: some View {
        
        List(){
            Section(header: Text("Kategorier")) {
                ForEach($prøve.kategorier){ kategori in
                    TextField("kategori.navn", text: kategori.navn)
                }
                
                Button {
                    prøve.kategorier.append(Kategori(navn: "Ny kategori", id: prøve.kategorier.count+1))
                    prøve.kategorierOgOppgaver.append((0..<prøve.oppgaver.count).map{_ in false})
                } label: {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
                
            }
            Section(header: Text("Tilbakemeldinger")) {
                ForEach(0..<prøve.tilbakemeldinger.count){ index in
                    tilbakemeldingsLinje(prøve: prøve, index: index)
                    
                }
                
            }
        }
            
        
    }
}

struct tilbakemeldingsLinje: View {
    @ObservedObject var prøve: Prøve
    var index: Int
    
    var body: some View{
        HStack {
            TextField("Tilbakemelding", text: $prøve.tilbakemeldinger[index].0)
            NumericTextField("Grense", number: $prøve.tilbakemeldinger[index].1, isDecimalAllowed: false).frame(width: 25, alignment: .trailing)
            Text("%")
        }
    }
}