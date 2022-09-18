//
//  karakterView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 15/08/2022.
//

import SwiftUI

struct karakterView: View {
    @Binding var poeng: [Poeng]
    var farge: Bool = false
    var maxPoeng: Float
    @Binding var elev: Elev
    
    
    var body: some View {
        if(elev.låstKarakter) {
            Text(finnKarakter(sumPoeng: poeng.map({ (poeng) -> Float in return poeng.poeng ?? 0;}).reduce(0, +)))
                .font(.title3)
                .fontWeight(.bold)
                .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                .border(.black)
                .background(farge ? .white:.orange)
                .multilineTextAlignment(.center)
                .onAppear(perform: {elev.karakter = finnKarakter(sumPoeng: poeng.map({ (poeng) -> Float in return poeng.poeng ?? 0;}).reduce(0, +))})
                
        }
        else{
            TextField("", text: $elev.karakter)
                .onAppear{
                    print(elev.navn + " " + elev.karakter)
                }
                .font(.title3)
                .fontWeight(.bold)
                .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                .border(.black)
                .background(farge ? .white:.orange)
                .multilineTextAlignment(.center)
        }
            
        
    }
    
    func finnKarakter(sumPoeng: Float) -> String{
        
        let fått_til: Float = sumPoeng/maxPoeng
        let desimalKarakter = fått_til*6
        return String(Int(round(desimalKarakter)))
           
    }
}

/*struct karakterView_Previews: PreviewProvider {
    static var previews: some View {
        karakterView()
    }
}*/
