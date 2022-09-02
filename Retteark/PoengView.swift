//
//  PoengView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 30/07/2022.
//

import SwiftUI

struct PoengView: View {
    @Binding var poeng: Float?
    
    var body: some View {
        NumericTextField(String(poeng ?? -1), number: $poeng, isDecimalAllowed: true)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            
    }
}

struct PoengView_Previews: PreviewProvider {
    @State static var poeng: Float? = 2.3
    static var previews: some View {
        PoengView(poeng: $poeng)
    }
}
