//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var prøve: Prøve = Prøve(elever: elever_test, oppgaver: oppgaver_test, kategorier: kategoier_test)
    @State var viserKategoriVisning: Bool = false
    
    var body: some View {
        VStack {
            Button("Kategorier") {
                viserKategoriVisning = true
            }
            .sheet(isPresented: $viserKategoriVisning, content: {
                kategoriView(viserKategoriVisning: $viserKategoriVisning, prøve: prøve)
            })
            
            poengTabellView(prøve: prøve)
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
