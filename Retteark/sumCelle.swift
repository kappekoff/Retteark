//
//  sumCelle.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 05/08/2022.
//

import SwiftUI

struct sumCelle: View {
    @Binding var poeng: [Poeng]
    var farge: Bool = false
    
    var body: some View {
        Text(String(poeng
                .map({ (poeng) -> Float in
                    return poeng.poeng ?? 0;})
                .reduce(0, +)))
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .background(farge ? .white:.orange)
            .multilineTextAlignment(.center)
    }
}

struct sumCelle_Previews: PreviewProvider {
    @State static var poeng: [Poeng] = [Poeng(id: [0], poeng: 2.3)]
    static var previews: some View {
        sumCelle(poeng: $poeng)
    }
}
