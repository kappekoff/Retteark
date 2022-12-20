//
//  klassesammendrag.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 20/12/2022.
//

import SwiftUI
import Charts


struct Stolpediagram: View {
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @ObservedObject var prøve: Prøve
    
    var karakterer: [Karakter] {
        finnKarakterSammensetning()
    }
    
    var body: some View {
        Chart {
            ForEach(karakterer) { karakter in
                BarMark(
                    x: .value("Karakter", karakter.type),
                    y: .value("Antall", karakter.count)
                )
            }
        }
    }
                
                
    func finnKarakterSammensetning() -> [Karakter] {
        var karakterer: [Karakter] = []
        for karakter in prøve.karaktergrenser.reversed() {
            karakterer.append(Karakter(type: karakter.karakter, count: 0))
        }
        
        for elev in prøve.elever{
            for j in 0..<karakterer.count {
                var karakter = elev.karakter
                if(elev.låstKarakter) {
                    karakter = prøve.finnKarakter(elevIndeks: prøve.elever.firstIndex{$0.id == elev.id}!)
                }
                if(karakter == karakterer[j].type){
                    karakterer[j].count += 1
                }
            }
        }
        
        return karakterer
    }
}


struct Karakter: Identifiable  {
    var type: String
    var count: Double
    var id = UUID()
}
