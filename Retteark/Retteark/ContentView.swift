//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI

struct ContentView: View {
    
    var prøve: Prøve
    @State var viserSheet: VisElevTilbakemleding? = nil
    
    var body: some View {
        VStack<<#Content: View#>> {
            Text(prøve.navn).font(.largeTitle)
            HStack {
                Button("Kategorier") {
                    viserSheet = .valgtKategorier
                }
                Button("Instillinger") {
                    viserSheet = .velgtInstillinger
                }
            }.buttonStyle(.borderedProminent)
            
            .sheet(item: $viserSheet, onDismiss: {viserSheet = nil}){ viserSheet in
                switch viserSheet{
                case .valgtKategorier:
                    kategoriView(viserSheet: $viserSheet, prøve: prøve)
                case .velgtInstillinger:
                    instillinger(prøve: prøve)
                default:
                    Text("Du skal aldri komme hit")
                }
            }
            poengTabellView(prøve: prøve)
        }
    }
}
