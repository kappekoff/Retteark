//
//  PoengView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 30/07/2022.
//

import SwiftUI

struct PoengView: View {
    @Binding var poeng: String
    
    var body: some View {
        //NumericTextField(String(poeng ?? 0), number: $poeng, isDecimalAllowed: true)
        tallEllerStrekVisning(tekst: $poeng, tittel: poeng)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            
    }
}
