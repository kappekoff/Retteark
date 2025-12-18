//
//  sumCelle.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 05/08/2022.
//

import SwiftUI
import SQLiteData

struct sumCelle: View {
    @Dependency(\.defaultDatabase) var database

    var oppgaver: [Oppgaver]
    @Binding var poenger: [(Poenger, Prover.ID)]
    var deltaker: Deltakere
    var indeks: Int
    

    var sum: String {
        sumAvPoeng()
    }
    
    var body: some View {
        Text(sum)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .background(indeks % 2 == 1  ? Color.background:.orange)
            .multilineTextAlignment(.center)


    }
    
    func sumAvPoeng() -> String  {
        var tallsum: Double = 0
        for oppgave in oppgaver {
            tallsum += hentPoengForOppgave(oppgaveId: oppgave.id) ?? 0
        }
        return String(tallsum)
    }
    
    func hentPoengForOppgave(oppgaveId: Oppgaver.ID) -> Double? {
        var formatter: NumberFormatter  = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        let poeng = poenger.first(where: {$0.0.oppgaveId == oppgaveId && $0.0.deltakerId == deltaker.id})?.0.poeng
        if let poeng = poeng {
            if let poengVerdi = formatter.number(from: poeng)?.doubleValue {
                return poengVerdi
            }
        }
        return nil
    }
}
