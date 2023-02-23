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
            HStack {
                Text("Klassesammendrag").font(.largeTitle)
                Button {
                    let docuementDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let outputfileURL: URL? = docuementDirectory.appendingPathComponent("\(prøve.navn) klassesammendrag")
                    exportPDF(outputfileURL: outputfileURL){
                        Klassesammendrag(visElevTilbakemleding:$visElevTilbakemleding , prøve: prøve)
                    } completion: { status, url in
                        if let url = url,status{
                            print(url)
                            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false) // 5
                            //UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
                            UIApplication.shared.windows.last?.rootViewController?.present(controller, animated: true)
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
                Text("Kategorier").font(.title)
                kategoriSammendrag(prøve: prøve)
                Text("Karakterer").font(.title)
                Stolpediagram(prøve: prøve).frame(height: 500)
            }
            
            Button {
                visElevTilbakemleding = nil
            } label: {
                Text("Lukk")
            }
        }
    }
    
    func gjennomsnittsElev() -> [Float]{
        var antallElever: Float = 0
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        var oppgaver:[Float] = prøve.oppgaver.map {_ in 0}
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
                .foregroundStyle(.blue)
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


struct kategoriSammendrag: View {
    
    @ObservedObject var prøve: Prøve
    let kategoriKolonner = [
        GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))]
    let farger: [Color] = [Color.teal, Color.red, Color.green, Color.indigo, Color.brown, Color.mint, Color.orange, Color.pink, Color.purple, Color.yellow, Color.gray, Color.cyan]
    
    var body: some View {
        LazyVGrid(columns: kategoriKolonner, spacing: 30) {
            ForEach(prøve.kategorier) { kategori in
                if let kategoriIndex = prøve.kategoriIndex(kategoriId: kategori.id) {
                    if(maxPoengKategori(kategoriIndex: kategoriIndex) > 0) {
                        VStack {
                            Text(prøve.kategorier[kategoriIndex].navn)
                            kakediagram(desimaltall: Double(elevPoengKategori(kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex)), farge:farger[kategoriIndex % farger.count]).frame(width: 150, height: 150, alignment: .center)
                            Text(String(elevPoengKategori(kategoriIndex: kategoriIndex)) + "/" + String(maxPoengKategori(kategoriIndex: kategoriIndex)))
                        }
                    }
                }
            }
        }
    }
    
    func elevPoengKategori(kategoriIndex: Int) -> Float {
        var sum: Float = 0
        for oppgave in prøve.oppgaver {
            if let oppgaveIndex = prøve.oppgaveIndexMedKjentKategori(oppgaveId: oppgave.id, kateogriIndex: kategoriIndex) {
                if(prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex].verdi){
                    sum += gjennomsnittsElev()[oppgaveIndex]
                    
                }
            }
        }
        return sum
    }
    
    func gjennomsnittsElev() -> [Float]{
        var antallElever: Float = 0
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        var oppgaver:[Float] = prøve.oppgaver.map({_ in 0})
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
    
    func maxPoengKategori(kategoriIndex: Int) -> Float {
        var sum: Float = 0
        for oppgave in prøve.oppgaver {
            if let oppgaveIndex = prøve.oppgaveIndexMedKjentKategori(oppgaveId: oppgave.id, kateogriIndex: kategoriIndex){
                if(prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex].verdi){
                    sum += prøve.oppgaver[oppgaveIndex].maksPoeng ?? 0
                }
            }
        }
        return sum
    }
}
