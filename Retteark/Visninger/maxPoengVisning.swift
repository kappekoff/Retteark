//
//  maxPoengVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/11/2022.
//

import SwiftUI

struct maxPoengVisning: View {
    @Binding var poeng: Float?
    
    var body: some View {
        NumericTextField(String(poeng ?? 0), number: $poeng, isDecimalAllowed: true)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            
    }
}
