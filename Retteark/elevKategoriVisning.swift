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
    let columns = [
        GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))
        ]
    let farger: [Color] = [Color.teal, Color.red, Color.green, Color.indigo, Color.brown, Color.mint, Color.orange, Color.pink, Color.purple, Color.yellow, Color.gray, Color.cyan]
    
    var body: some View {
        HStack {
            Text(elev.navn).font(.largeTitle).frame(alignment: .center)
            Button {
                exportPDF(filnavn: prøve.navn + " " + elev.navn){
                    elevTilbakemeldingVisning(elev: elev, visElevTilbakemleding:$visElevTilbakemleding , prøve: prøve)
                } completion: { status, url in
                    if let url = url,status{
                        print(url)
                    }
                    else {
                        print("Klarte ikke produsere pdf")
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.up.fill")
            }

        }
        ScrollView {
            VStack(alignment: .listRowSeparatorLeading){
                
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(0..<prøve.kategorier.count) { kategoriIndex in
                        
                        if(maxPoengKategori(kategoriIndex: kategoriIndex) > 0) {
                            VStack {
                                Text(prøve.kategorier[kategoriIndex].navn)
                                kakediagram(desimaltall: Double(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex)), farge:farger[kategoriIndex % farger.count]).frame(width: 150, height: 150, alignment: .center)
                                Text(String(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)) + "/" + String(maxPoengKategori(kategoriIndex: kategoriIndex)))
                            }
                        }
                    }
                }
                Text(lagElevtilbakemelding()).frame(alignment: .leading)
                TextField("Framovermelding", text: $prøve.elever[prøve.elever.firstIndex{$0.id == elev.id}!].framovermelding, axis: .vertical)
                if(prøve.visEleverKarakter){
                    Text("Karakter: " + elev.karakter)
                }
                
            }.padding(20)
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
    
    func lagElevtilbakemelding() -> String {
        var høy: String = prøve.tilbakemeldinger[0].tekst + ": "
        var middels: String = prøve.tilbakemeldinger[1].tekst + ": "
        var lav: String = prøve.tilbakemeldinger[2].tekst + ": "
        for kategoriIndex in 0..<prøve.kategorier.count {
            if(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex) > (prøve.tilbakemeldinger[0].nedreGrense ?? 66) / 100) {
                høy += prøve.kategorier[kategoriIndex].navn + ", "
            }
            
            else if(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex) > (prøve.tilbakemeldinger[1].nedreGrense ?? 33) / 100) {
                middels += prøve.kategorier[kategoriIndex].navn + ", "
            }
            
            else if(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex) >= (prøve.tilbakemeldinger[2].nedreGrense ?? 0)/100) {
                lav += prøve.kategorier[kategoriIndex].navn + ", "
            }
            
        }
        middels = String(middels.dropLast(2))
        middels += "\n"
        høy = String(høy.dropLast(2))
        høy += "\n"
        lav = String(lav.dropLast(2))
        lav += "\n"
        return (høy + middels + lav)
    }
        
}
