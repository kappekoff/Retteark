//
//  sumCelle.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 05/08/2022.
//

import SwiftUI

struct sumCelle: View {
    @ObservedObject var prøve: Prøve
    var elevIndeks: Int
    var formatter: NumberFormatter  = NumberFormatter()

    
    var body: some View {
        Text(sumAvPoeng())
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .background(elevIndeks % 2 == 1 ? Color.background:.orange)
            .multilineTextAlignment(.center)
    }
    
    func sumAvPoeng() -> String {

        var sum: Float = 0
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        for oppgave in prøve.oppgaver {
            if let oppgaveIndeks = prøve.oppgaveIndexMedKjentElev(oppgaveId: oppgave.id, elevIndex: elevIndeks){
                if let tall = formatter.number(from: prøve.poeng[elevIndeks][oppgaveIndeks].poeng) as? Double {
                    sum += Float(tall)
                }
            }
        }
        return String(sum)
    }
}
