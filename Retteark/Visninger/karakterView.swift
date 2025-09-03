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
    
    
    var prøveId: Prover.ID
    var deltakerId: Deltakere.ID
    let indeks: Int
    
    @Binding var låstKarakter: Bool
    @Binding var endretPoeng: Int

    
    @State var oppgaver: [Oppgaver] = []
    @State var poeng: Poenger? = nil
    @State var deltaker: Deltakere? = nil
    @State var karakter = ""
    
    let karaktergrenser = Testdata().karaktergrenser_test
    var body: some View {
        
        Group {
            if(låstKarakter) {
                TextField("", text: $karakter)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .border(.black)
                    .background(indeks % 2 == 1  ? Color.background:.orange)
                    .multilineTextAlignment(.center)
                    .onChange(of: karakter) { _, newValue in
                        if let deltaker = deltaker {
                            withErrorReporting {
                                try database.write { db in
                                    if(deltaker.låstKarakter) {
                                        let midlertidigDeltaker = Deltakere(id: deltakerId, navn: deltaker.navn, proveId: prøveId, låstKarakter: true, karakter: newValue)
                                        try Deltakere.update(midlertidigDeltaker)
                                            .execute(db)
                                    }
                                }
                            }
                        }
                    }
                
            }
            else{
                Text(karakter)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .border(.black)
                    .background(indeks % 2 == 1 ? Color.background:.orange)
                    .multilineTextAlignment(.center)
                    .task {
                        karakter = await finnKarakter()
                    }
                    .onChange(of: endretPoeng) {
                        Task {
                            karakter = await finnKarakter()
                        }
                    }
            }
        }
        .task {
            await hentDeltaker()
        }
        
    }
    
    func hentDeltaker() async {
        await withErrorReporting {
            try await database.read { db in
                deltaker = try Deltakere
                    .where { $0.id == self.deltakerId}
                    .fetchOne(db)
            }
        }
    }
    
    func hentOppgaver() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaver = try Oppgaver
                    .where { $0.proveId == self.prøveId}
                    .fetchAll(db)
            }
        }
    }
    
    func hentPoeng(oppgaveId: Oppgaver.ID) async {
        await withErrorReporting {
            try await database.read { db in
                poeng = try Poenger
                    .where { $0.deltakerId == self.deltakerId && $0.oppgaveId == oppgaveId }
                    .fetchOne(db)
            }
        }
    }

    func sumAvPoeng() async -> Double  {
        var formatter: NumberFormatter  = NumberFormatter()
        var tallsum: Double = 0
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        for oppgave in oppgaver {
            await hentPoeng(oppgaveId: oppgave.id)
            if let poeng = poeng {
                if let poengVerdi = formatter.number(from: poeng.poeng)?.doubleValue {
                    tallsum += poengVerdi
                }
            }
        }
        return tallsum
    }
    
    func finnKarakter() async -> String {
        await hentOppgaver()
        let maxPoeng = oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)
        let sumPoeng = await sumAvPoeng()
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
