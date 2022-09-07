//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var prøve: Prøve = Prøve(elever: elever_test, oppgaver: oppgaver_test, kategorier: kategoier_test)
    @State var viserSheet: VisElevTilbakemleding? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button("Kategorier") {
                    viserSheet = .valgtKategorier
                }
                Button("Instillinger") {
                    viserSheet = .velgtInstillinger
                }
            }
            
            .sheet(item: $viserSheet, onDismiss: {viserSheet = nil}){ viserSheet in
                switch viserSheet{
                case .valgtKategorier:
                    kategoriView(viserSheet: $viserSheet, prøve: prøve)
                case .velgtInstillinger:
                    instillinger(prøve: prøve)
                case .valgtElev(let elev):
                    Text("Skal aldri komme hit .valgtElev(elev: prøve.elever[0]")
                }
            }
            poengTabellView(prøve: prøve)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
