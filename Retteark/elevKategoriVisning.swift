//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI

struct elevTilbakemeldingVisning: View {
    var elev: Elev
    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
    @ObservedObject var prøve: Prøve
    
    var body: some View {
        VStack{
            HStack {
                Button("Tilbake") {
                    visElevTilbakemleding = nil
                }
            }
            Text(elev.navn)
            ForEach(0..<prøve.kategorier.count) { kategoriIndex in
                /*kakediagram(desimaltall: Double(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex)), farge:Color.red).frame(width: 200, height: 200, alignment: .center)*/
                Text(String(Double(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex))))
            }
        }
            
        }
    
    func maxPoengKategori(kategoriIndex: Int) -> Float {
        var sum: Float = 0
        for oppgaveIndex in 0..<prøve.kategorierOgOppgaver[kategoriIndex].count {
            if(prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex]){
                sum += prøve.oppgaver[oppgaveIndex].maksPoeng ?? 0
            }
        }
        return sum
    }
    
    func elevPoengKategori(elevIndex: Int, kategoriIndex: Int) -> Float {
        var sum: Float = 0
        for oppgaveIndex in 0..<prøve.kategorierOgOppgaver[kategoriIndex].count {
            if(prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex]){
                sum += prøve.poeng[elevIndex][oppgaveIndex].poeng ?? 0
            }
        }
        return sum
    }
        
    }
