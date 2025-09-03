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

    var deltakerID: Deltakere.ID
    var oppgaveID: Oppgaver.ID
    
    @State var poeng: Poenger? = nil
    @State var poengVerdi = ""
    @Binding var endretPoeng: Int
    
    var body: some View {
        Group {
            if let poeng = poeng {
                tallEllerStrekVisning(tekst: $poengVerdi, tittel: poeng.poeng)
                    .font(.title3)
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .border(.black)
                    .multilineTextAlignment(.center)
                    .onChange(of: poengVerdi) { _, _ in
                        endretPoeng += 1
                        Task {
                            self.poeng?.poeng = poengVerdi
                            await lagrePoeng()
                        }
                    }
                    .onAppear {
                        poengVerdi = poeng.poeng
                    }
            } else {
                Text("Laster...").task {
                    await hentPoeng()
                }
            }
        }
    }
    
    func hentPoeng() async {
        await withErrorReporting {
            try await database.read { db in
                poeng = try Poenger
                    .where{$0.deltakerId == deltakerID && $0.oppgaveId == oppgaveID}
                    .fetchOne(db)
            }
        }
    }
    
    func lagrePoeng() async{
        await withErrorReporting {
            try await database.write { db in
                if let poeng = poeng {
                    let midlertidigPoeng = poeng
                    try Poenger.update(midlertidigPoeng).execute(db)
                }
            }
        }
    }
        
}
