//
//  PoengView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 30/07/2022.
//

import SwiftUI

struct PoengView: View {
    @ObservedObject var prøve: Prøve
    @Binding var poeng: Poeng
    
   
    
    var body: some View {
        tallEllerStrekVisning(tekst: $poeng.poeng, tittel: poeng.poeng)
            .font(.title3)
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .border(.black)
            .multilineTextAlignment(.center)
            .onSubmit {
                if(poeng.poeng == "") {
                    poeng.poeng = String((prøve.oppgaver[optional: prøve.oppgaver.firstIndex(where: {$0.id == poeng.oppgaveId})!]?.maksPoeng!)!)
                }
                
            }
            
    }
}
