//
//  PoengView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 30/07/2022.
//

import SwiftUI
import SharingGRDB

struct PoengView: View {
    @Dependency(\.defaultDatabase) var database

    var deltaker: Deltakere
    var oppgave: Oppgaver
    
    
    @Binding var poenger: [(Poenger, Prover.ID)]
    var poengVerdi: String? {
        return poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0.poeng
    }
    @Binding var endretPoeng: Int
    @State private var lagrePoengTimer: Task<Void, Never>?
    
    var body: some View {
        Group {
            if(poengVerdi != nil) {
                let binding = Binding<String>(get: {poengVerdi ?? ""},
                                              set: {nyVerdi in
                    if let index = poenger.firstIndex(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id}) {
                        poenger[index].0.poeng = nyVerdi
                    }})
                poengInputfelt(binding: binding)
            } else {
                Text("Laster...")
            }
        }
    }
    
    func lagrePoeng() async{
        await withErrorReporting {
            try await database.write { db in
                if let poeng = poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0{
                    let midlertidigPoeng = Poenger(oppgaveId: poeng.oppgaveId, deltakerId: poeng.deltakerId, poeng: poengVerdi ?? "", id: poeng.id)
                    try Poenger.update(midlertidigPoeng).execute(db)
                }
            }
        }
    }
    
    private func poengInputfelt(binding: Binding<String>) -> some View {
        tallEllerStrekVisning(tekst: binding, tittel: binding.wrappedValue)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            .onChange(of: binding.wrappedValue) {
                endretPoeng += 1
                lagrePoengTimer?.cancel()
                lagrePoengTimer = Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    await lagrePoeng()
                }
            }
    }

}

