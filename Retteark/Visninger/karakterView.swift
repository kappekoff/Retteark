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
    let formatter: NumberFormatter = NumberFormatter()
    
    
    var body: some View {
        if(prøve.elever[elevIndeks].låstKarakter) {
            Text(finnKarakter(sumPoeng: sumAvPoeng()))
                .font(.title3)
                .fontWeight(.bold)
                .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                .border(.black)
                .background(elevIndeks % 2 == 1 ? Color(UIColor.systemBackground):.orange)
                .multilineTextAlignment(.center)
                .onAppear(perform: {prøve.elever[elevIndeks].karakter = finnKarakter(sumPoeng: sumAvPoeng())})
                .onChange(of: prøve){_ in
                    prøve.elever[elevIndeks].karakter = finnKarakter(sumPoeng: sumAvPoeng())
                }
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
    
    func sumAvPoeng() -> Float {

        var sum: Float = 0
        formatter.numberStyle = .decimal
        for oppgave in prøve.oppgaver {
            if let oppgaveIndeks = prøve.oppgaveIndex(oppgaveId: oppgave.id){
                if let tall = formatter.number(from: prøve.poeng[elevIndeks][oppgaveIndeks].poeng) as? Float {
                    sum += tall
                }
            }
        }
        return sum
    }

    
    func finnKarakter(sumPoeng: Float) -> String{
        let maxPoeng = prøve.oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)
        let fått_til: Float = sumPoeng/maxPoeng
        if(fått_til > 1 || fått_til < 0) {
            return "?"
        }
        else if(fått_til >= 0.9967){
            return "6"
        }
        else if(fått_til >= 0.9355){
            return "6-"
        }
        else if(fått_til >= 0.9032){
            return "6/5"
        }
        else if(fått_til >= 0.8710){
            return "5/6"
        }
        else if(fått_til >= 0.8387){
            return "5+"
        }
        else if(fått_til >= 0.8065){
            return "5"
        }
        else if(fått_til >= 0.7742){
            return "5-"
        }
        else if(fått_til >= 0.7419){
            return "5/4"
        }
        else if(fått_til >= 0.7097){
            return "4/5"
        }
        else if(fått_til >= 0.6774){
            return "4+"
        }
        else if(fått_til >= 0.6452){
            return "4"
        }
        else if(fått_til >= 0.6129){
            return "4-"
        }
        else if(fått_til >= 0.5806){
            return "4/3"
        }
        else if(fått_til >= 0.5484){
            return "3/4"
        }
        else if(fått_til >= 0.5161){
            return "3+"
        }
        else if(fått_til >= 0.4839){
            return "3"
        }
        else if(fått_til >= 0.4516){
            return "3-"
        }
        else if(fått_til >= 0.4194){
            return "3/2"
        }
        else if(fått_til >= 0.3871){
            return "2/3"
        }
        else if(fått_til >= 0.3548){
            return "2+"
        }
        else if(fått_til >= 0.3226){
            return "2"
        }
        else if(fått_til >= 0.2903){
            return "2-"
        }
        else if(fått_til >= 0.2581){
            return "2/1"
        }
        else if(fått_til >= 0.2258){
            return "1/2"
        }
        else if(fått_til >= 0.1935){
            return "1+"
        }
        else {
            return "1"
        }
    }
}
