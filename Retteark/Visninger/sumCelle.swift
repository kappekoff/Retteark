//
//  sumCelle.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 05/08/2022.
//

import SwiftUI
import SharingGRDB

struct sumCelle: View {
    @Dependency(\.defaultDatabase) var database

    var prøveId: Prover.ID
    var deltakerId: Deltakere.ID
    var indeks: Int
    @Binding var endretPoeng: Int
    
    @State var oppgaver: [Oppgaver] = []
    @State var poeng: Poenger? = nil
    @State var sum: String = ""
    
    var body: some View {
        Text(sum)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .background(indeks % 2 == 1  ? Color.background:.orange)
            .multilineTextAlignment(.center)
            .task {
                await hentOppgaver()
                sum = await sumAvPoeng()
            }
            .onChange(of: endretPoeng) {
                Task {
                    sum = await sumAvPoeng()
                }
                
            }
    }
    
    func sumAvPoeng() async -> String  {

        var tallsum: Double = 0
        
        for oppgave in oppgaver {
            tallsum += await hentPoengForOppgave(oppgaveId: oppgave.id) ?? 0
        }
        
        return String(tallsum)
    }
    
    func hentPoengForOppgave(oppgaveId: Oppgaver.ID) async -> Double? {
        var formatter: NumberFormatter  = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        await hentPoeng(oppgaveId: oppgaveId)
        if let poeng = poeng {
            if let poengVerdi = formatter.number(from: poeng.poeng)?.doubleValue {
                return poengVerdi
            }
        }
        return nil
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
    
}
