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

    var poengId: Poenger.ID
    @State var poeng: Poenger? = nil
    
    var body: some View {
        Group {
            if let poeng = poeng {
                tallEllerStrekVisning(tekst: Binding(get: {poeng.poeng}, set: { nyVerdi in
                    self.poeng?.poeng = nyVerdi
                }), tittel: poeng.poeng)
                    .font(.title3)
                    .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                    .border(.black)
                    .multilineTextAlignment(.center)
                    .onChange(of: poeng.poeng) { _, _ in
                      Task {
                        klasseoversikt.lagreKlasser()
                      }
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
                poeng = try Poenger.fetchOne(db, id: self.poengId)
            }
        }
    }
        
}
