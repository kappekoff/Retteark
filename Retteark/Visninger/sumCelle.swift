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
    var elevIndeks: Int
    var formatter: NumberFormatter  = NumberFormatter()
    
    @State var oppgaver: [Oppgaver] = []
    @State var poeng: Poenger? = nil
    @State var sum: String = ""
    
    var body: some View {
        Text(sum)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .background(elevIndeks % 2 == 1  ? Color.background:.orange)
            .multilineTextAlignment(.center)
            .task {
                await hentOppgaver()
                sum = await sumAvPoeng()
            }
    }
    
    func sumAvPoeng() async -> String  {

        var tallsum: Double = 0
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        for oppgave in oppgaver {
            Task {
                await hentPoeng(oppgaveId: oppgave.id)
                if let poeng = poeng {
                    if let poengVerdi = formatter.number(from: poeng.poeng)?.doubleValue {
                        tallsum += poengVerdi
                    }
                }
            }
        }
        return String(tallsum)
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
