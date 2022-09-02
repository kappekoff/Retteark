//
//  kategoriView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI


struct kategoriView: View {
    @Binding var viserKategoriVisning: Bool
    @ObservedObject var prøve: Prøve
    
    
    
    var body: some View {
        ScrollView {
            
       
            VStack {
                Text("Kategoier og oppgaver").font(.largeTitle)
                ForEach(0..<prøve.kategorier.count){kategoriIndex in
                    Text(prøve.kategorier[kategoriIndex].navn)
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(0..<prøve.oppgaver.count){oppgaveIndex in
                        Toggle(prøve.oppgaver[oppgaveIndex].navn, isOn: $prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex])
                    }
                    
                }
                Button("Tilbake") {
                    viserKategoriVisning = false

                }
            }
        }
        
    }
}

/*struct kategoriView_Previews: PreviewProvider {
    static var previews: some View {
        kategoriView()
    }
}*/
