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
    var formatter: NumberFormatter  = NumberFormatter()
    @State
    
    
    var body: some View {
        Text(String(poeng
                .map({ (poeng) -> Float in
                    return poeng.poeng ?? 0;})
                .reduce(0, +)))
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .background(farge ? Color(UIColor.systemBackground):.orange)
            .multilineTextAlignment(.center)
            .onAppear() {
                
            }
    }
    
    func sumAvPoeng() -> Float {

        let sum: Float = 0
        formatter.numberStyle = .decimal
        for element in poeng {
            if let tall = formatter.number(from: element.poeng) {
                
            }
        }
        return sum
    }
}
