//
//  PoengView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 30/07/2022.
//

import SwiftUI

struct PoengView: View {
    @Environment(Klasseoversikt.self) var klasseoversikt
    @Binding var poeng: Poeng
    
    var body: some View {
        tallEllerStrekVisning(tekst: $poeng.poeng, tittel: poeng.poeng)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            .onChange(of: poeng) { _, _ in
              Task {
                klasseoversikt.lagreKlasser()
              }
            }
            
    }
}
