//
//  klassesammendrag.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 20/12/2022.
//

import SwiftUI
import Charts

struct Klassesammendrag: View {
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @ObservedObject var prøve: Prøve
    
    var body: some View {
        VStack {
            Text("Klassesammendrag").font(.largeTitle)
            Stolpediagram(prøve: prøve)
            Button {
                visElevTilbakemleding = nil
            } label: {
                Text("Lukk")
            }
        }
        

    }
}

struct Stolpediagram: View {

    @ObservedObject var prøve: Prøve
    var karakterer: [Karakter] {
        finnKarakterSammensetning()
    }
    var yAkse: [Int] {
        stride(from: 0, to: (karakterer.max(by: {$0.count < $1.count})?.count ?? 29) + 1, by: 1).map{$0}
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
        .chartXAxis(content: {
            AxisMarks { value in
                AxisValueLabel {
                    if let karakter = value.as(String.self) {
                        Text(karakter)
                            .font(.title2)
                        }
                    }
                }
            })
        .chartYAxis(content: {
            AxisMarks(position: .leading, values: yAkse) { value in
                AxisValueLabel {
                    if let antall = value.as(Int.self) {
                        Text(String(antall))
                            .font(.title2)
                        }
                }
                AxisGridLine(
                    centered: true,
                    stroke: StrokeStyle(dash: [2]))
                        .foregroundStyle(Color.gray)
                }
        })
    }
    
    func gjennomsnittsElev() -> [Float]{
        var antallElever: Float = 0
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        var oppgaver:[Float] = []
        for elev in prøve.elever {
            if let elevIndeks = prøve.poengRad(elevId: elev.id) {
                if(elevHarLevert(elevIndeks: elevIndeks)) {
                    antallElever += 1
                    for i in 0..<prøve.oppgaver.count {
                        if let oppgaveIndeks = prøve.oppgaveIndexMedKjentElev(oppgaveId: prøve.oppgaver[i].id, elevIndex: elevIndeks) {
                            let tall = formatter.number(from: prøve.poeng[elevIndeks][oppgaveIndeks].poeng) as? Float
                            if(tall != nil) {
                               oppgaver[i]  += tall!
                            }
                        }
                    }
                    
                }
            }
        }
        oppgaver = oppgaver.map { $0/antallElever}
        return oppgaver
    }
    
    func elevHarLevert(elevIndeks: Int) -> Bool {
        for oppgave in prøve.oppgaver {
            if let oppgaveIndeks = prøve.oppgaveIndexMedKjentElev(oppgaveId: oppgave.id, elevIndex: elevIndeks) {
                for tegn in prøve.poeng[elevIndeks][oppgaveIndeks].poeng {
                    if tegn.isNumber {
                        return true
                    }
                    
                }
            }
        }
        return false
    }
                
                
    func finnKarakterSammensetning() -> [Karakter] {
        var karakterer: [Karakter] = []
        for karakter in prøve.karaktergrenser.reversed() {
            if(karakterer.firstIndex(where: {$0.type == String(karakter.karakter[karakter.karakter.startIndex])}) == nil){
                karakterer.append(Karakter(type: String(karakter.karakter[karakter.karakter.startIndex]), count: 0))
            }
        }
        
        for elev in prøve.elever{
            for j in 0..<karakterer.count {
                var karakter = String(elev.karakter[elev.karakter.startIndex])
                if(elev.låstKarakter) {
                    karakter = prøve.finnKarakter(elevIndeks: prøve.elever.firstIndex{$0.id == elev.id}!)
                    karakter = String(karakter[karakter.startIndex])
                }
                if(karakter == karakterer[j].type){
                    karakterer[j].count += 1
                }
            }
        }
        return karakterer
    }
}


struct Karakter: Identifiable, Equatable  {
    var type: String
    var count: Int
    var id = UUID()
}
