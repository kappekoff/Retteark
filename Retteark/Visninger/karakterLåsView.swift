//
//  karakterLåsView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 01/09/2025.
//

import SwiftUI
import SQLiteData

struct karakterLa_sView: View {
    @Dependency(\.defaultDatabase) var database
    
    var deltaker: Deltakere
    var indeks: Int
    @Binding var låstKarakter: Bool
    
    
    var body: some View {
        Button(action: {
            Task {
                await låsKarakarakterForDeltaker()
            }
        }, label: {
            Image(systemName: låstKarakter ? "lock.fill" : "lock.open.fill")
        })
        .font(.title3)
        .fontWeight(.bold)
        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
        .border(.black)
        .background(indeks % 2 == 1 ? Color.background:.orange)
        .multilineTextAlignment(.center)
        .onAppear {
            låstKarakter = deltaker.låstKarakter
        }

    }
    
    func låsKarakarakterForDeltaker() async {
        låstKarakter.toggle()
        var midlertidigDeltaker = deltaker
        midlertidigDeltaker.låstKarakter = låstKarakter
        withErrorReporting {
            try database.write { db in
                try Deltakere.update(midlertidigDeltaker).execute(db)
            }
        }
    }
}
