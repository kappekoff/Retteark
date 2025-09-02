//
//  karakterLåsView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 01/09/2025.
//

import SwiftUI
import SharingGRDB

struct karakterLa_sView: View {
    @Dependency(\.defaultDatabase) var database
    
    var deltakerID: Deltakere.ID
    var elevIndeks: Int
    
    @State var låstKarakter: Bool = false
    @State var deltaker: Deltakere? = nil
    
    var body: some View {
        Button(action: {
            låsKarakarakterForDeltaker()
            Task {
                await hentDeltaker()
                låstKarakter = deltaker?.låstKarakter ?? false
            }
        }, label: {
            Image(systemName: låstKarakter ? "lock.fill" : "lock.open.fill")
        })
        .font(.title3)
        .fontWeight(.bold)
        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
        .border(.black)
        .background(elevIndeks % 2 == 1 ? Color.background:.orange)
        .multilineTextAlignment(.center)
        .task{
            await hentDeltaker()
            låstKarakter = deltaker?.låstKarakter ?? false
        }
    }
    
    func låsKarakarakterForDeltaker() {
        withErrorReporting {
            try database.write { db in
                var midlertidigDeltaker = deltaker!
                midlertidigDeltaker.låstKarakter.toggle()
                try Deltakere.update(midlertidigDeltaker).execute(db)
            }
        }
    }
    
    func hentDeltaker() async {
        await withErrorReporting {
            try await database.read { db in
                deltaker = try Deltakere
                    .where { $0.id == self.deltakerID}
                    .fetchOne(db)
            }
        }
    }
}
