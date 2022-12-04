//
//  karakterView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 15/08/2022.
//

import SwiftUI

struct karakterView: View {
    @ObservedObject var prøve: Prøve
    let elevIndeks: Int
    
    
    var body: some View {
        if(prøve.elever[elevIndeks].låstKarakter) {
            Text(prøve.finnKarakter(elevIndeks: elevIndeks))
                .font(.title3)
                .fontWeight(.bold)
                .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                .border(.black)
                .background(elevIndeks % 2 == 1 ? Color.background:.orange)
                .multilineTextAlignment(.center)
        }
        else{
            TextField("", text: $prøve.elever[elevIndeks].karakter)
                .font(.title3)
                .fontWeight(.bold)
                .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                .border(.black)
                .background(elevIndeks % 2 == 1  ? .white:.orange)
                .multilineTextAlignment(.center)
        }
    }

}
