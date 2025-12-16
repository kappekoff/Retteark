//
//  karakterView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 15/08/2022.
//

import SwiftUI
import SharingGRDB

struct karakterView: View {
    @Dependency(\.defaultDatabase) var database
    
    var deltaker: Deltakere
    var oppgaver: [Oppgaver]
    @Binding var poenger: [(Poenger, Prover.ID)]
    let indeks: Int
    
    @Binding var låstKarakter: Bool

    var karakter: String {
        finnKarakter()
    }
    
    @State var låstkarakter = ""
    
    var lagerPDF: Bool = false
    
    
    var body: some View {
        Group {
            if (lagerPDF) {
                Text(deltaker.låstKarakter ? deltaker.karakter : finnKarakter())
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .background(indeks % 2 == 1 ? Color.background:.orange)
                    .multilineTextAlignment(.center)
            }
            else {
                if(låstKarakter) {
                    TextField("", text: $låstkarakter)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                        .background(indeks % 2 == 1  ? Color.background:.orange)
                        .multilineTextAlignment(.center)
                        .onChange(of: låstkarakter) { _, newValue in
                            withErrorReporting {
                                try database.write { db in
                                    if(deltaker.låstKarakter) {
                                        var midlertidigDeltaker = deltaker
                                        midlertidigDeltaker.låstKarakter = true
                                        midlertidigDeltaker.karakter = newValue
                                        try Deltakere.update(midlertidigDeltaker)
                                            .execute(db)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            låstkarakter = deltaker.karakter
                        }

                    
                }
                else {
                    Text(karakter)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                        .background(indeks % 2 == 1 ? Color.background:.orange)
                        .multilineTextAlignment(.center)

                }
            }
        }
    }
    
    func sumAvPoeng() -> Double  {
        var tallsum: Double = 0
        for oppgave in oppgaver {
            let poeng =  hentPoengForOppgave(oppgaveId: oppgave.id)
            if let poeng = poeng {
                tallsum += poeng
            }
        }
        return tallsum
    }
    
    func hentPoengForOppgave(oppgaveId: Oppgaver.ID) -> Double? {
        let formatter: NumberFormatter  = NumberFormatter()
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
    
    func finnKarakter() -> String {
        let karaktergrenser = Testdata().karaktergrenser_test
        let maxPoeng = oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)
        let sumPoeng = sumAvPoeng()
        let fått_til = sumPoeng/maxPoeng
        
        if (fått_til > 1 || fått_til < 0) {
            return "?"
        }
        for karaktergrense in karaktergrenser {
            guard(karaktergrense.grense != nil) else {
                continue
            }
            if(fått_til >= karaktergrense.grense!/100) {
                return karaktergrense.karakter
            }
        }
        
        return "??"
    }

}
