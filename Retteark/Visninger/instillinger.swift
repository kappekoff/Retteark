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
            Section(header: Text("Kategorier")) {
                ForEach($prøve.kategorier){ kategori in
                    TextField("kategori.navn", text: kategori.navn)
                }
                Button {
                    prøve.leggTilKategori()
                } label: {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
            }
            Section(header: Text("Tilbakemeldinger")) {
                ForEach($prøve.tilbakemeldinger, id: \.self){ tilbakemelding in
                    HStack {
                        TextField("Tilbakemelding", text: tilbakemelding.tekst)
                        NumericTextField("Grense", number: tilbakemelding.nedreGrense, isDecimalAllowed: false).frame(width: 25, alignment: .trailing)
                        Text("%")
                    }
                }
            }
            Section(header: Text("Om prøven")){
                Toggle("Vis elever karakter", isOn: $prøve.visEleverKarakter)
            }
        }
        Button("Lukk") {
            visElevTilbakemleding = nil
        }
    }
}

