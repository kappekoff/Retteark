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
        VStack {
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
        
    }
}
