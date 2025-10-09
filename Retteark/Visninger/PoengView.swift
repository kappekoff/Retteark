//
//  PoengView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 30/07/2022.
//

import SwiftUI
import SharingGRDB

struct PoengView: View {
    @Environment(Klasseoversikt.self) var klasseoversikt
    @Dependency(\.defaultDatabase) var database

    var deltaker: Deltakere
    var oppgave: Oppgaver
    
    @Binding var poenger: [Poenger]
    @State var poengVerdi: String? = nil
    @Binding var endretPoeng: Int
    
    var body: some View {
        Group {
            if let binding = Binding($poengVerdi) {
                tallEllerStrekVisning(tekst: binding, tittel: binding.wrappedValue)
                    .font(.title3)
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .border(.black)
                    .multilineTextAlignment(.center)
                    .onChange(of: binding.wrappedValue) {
                        endretPoeng += 1
                        Task {
                            await lagrePoeng()
                        }
                        if let i = poenger.firstIndex(where: {$0.oppgaveId == oppgave.id && $0.deltakerId == deltaker.id}) {
                            poenger[i].poeng = binding.wrappedValue
                        }
                    }

            } else {
                Text("Laster...")
                    .onAppear {
                        poengVerdi = poenger.first(where: {$0.oppgaveId == oppgave.id && $0.deltakerId == deltaker.id})?.poeng
                    }
            }
        }
    }
    
    func lagrePoeng() async{
        await withErrorReporting {
            try await database.write { db in
                if let poeng = poenger.first(where: {$0.oppgaveId == oppgave.id && $0.deltakerId == deltaker.id}){
                    let midlertidigPoeng = Poenger(oppgaveId: poeng.oppgaveId, deltakerId: poeng.deltakerId, poeng: poengVerdi ?? "", id: poeng.id)
                    try Poenger.update(midlertidigPoeng).execute(db)
                }
            }
        }
    }
        
}
