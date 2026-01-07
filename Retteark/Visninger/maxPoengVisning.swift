//
//  maxPoengVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/11/2022.
//

import SwiftUI
import SQLiteData

struct maxPoengVisning: View {
    @Binding var oppgave: Oppgaver
    @Dependency(\.defaultDatabase) var database

    
    var body: some View {
        NumericTextField(String(oppgave.maksPoeng ?? 0), number: $oppgave.maksPoeng, isDecimalAllowed: true)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            .onChange(of: oppgave) {
                let oppgaveSomSkalLagres = oppgave
                Task {
                    await withErrorReporting {
                        try await database.write { db in
                            try Oppgaver.update(oppgaveSomSkalLagres)
                                .execute(db)
                        }
                    }
                }
            }
    }
}
