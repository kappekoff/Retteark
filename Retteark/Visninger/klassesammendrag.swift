//
//  klassesammendrag.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 20/12/2022.
//

import SwiftUI
import Charts
import SQLiteData

struct Klassesammendrag: View {
    @Dependency(\.defaultDatabase) var database
    @Binding var visElevTilbakemleding: VisElevTilbakemleding?
    @State var visFilvelger: Bool = false
    let prøveId: Prover.ID
    
    @State var prøve: Prover? = nil
    @State var deltakere: [Deltakere] = []
    @State var oppgaver : [Oppgaver] = []
    @State var kategorier: [Kategorier] = []
    @State var poenger: [(Poenger, Prover.ID)] = []
    @State var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Klassesammendrag").font(.largeTitle)
                Button {
                  visFilvelger.toggle()
                }
                 label: {
                    Image(systemName: "square.and.arrow.up.fill")
                }
                 .fileExporter(isPresented: $visFilvelger, document: PDFDocument(pdfData: Data()), contentType: .pdf, defaultFilename: "\(prøve?.navn ?? "Fant ikke prøve") klassesammendrag.pdf") { result in
                   switch result {
                    case .success(let file):
                     lagPDF(innhold: VStack {
                         Text(prøve?.navn ?? "Fant ikke prøve").font(.largeTitle)
                         Text("Kategorier").font(.title)
                         kategoriSammendrag(prøve: $prøve, deltakere: $deltakere, oppgaver: $oppgaver, kategorier: $kategorier, poenger: $poenger, oppgaverKategorier: $oppgaverKategorier)
                         Text("Karakterer").font(.title)
                         Stolpediagram(prøve: $prøve, deltakere: $deltakere, oppgaver: $oppgaver, kategorier: $kategorier, poenger: $poenger, oppgaverKategorier: $oppgaverKategorier).frame(height: 500)
                     }, filplassering: file)
                    case .failure(let error):
                     print(error)
                  }
                }
            }
            ScrollView {
                Text("Kategorier").font(.title)
                kategoriSammendrag(prøve: $prøve, deltakere: $deltakere, oppgaver: $oppgaver, kategorier: $kategorier, poenger: $poenger, oppgaverKategorier: $oppgaverKategorier)
                Text("Karakterer").font(.title)
                Stolpediagram(prøve: $prøve, deltakere: $deltakere, oppgaver: $oppgaver, kategorier: $kategorier, poenger: $poenger, oppgaverKategorier: $oppgaverKategorier).frame(height: 500)
            }
            .task {
                await hentDeltakere()
                await hentPrøve()
                await hentOppgaver()
                await hentKategorier()
                await hentPoenger()
                await hentOppgaverKategorierForProve()
            }
            
            Button {
                visElevTilbakemleding = nil
            } label: {
                Text("Lukk")
            }
        }
    }
    
    func hentPoenger() async {
         await withErrorReporting {
             try await database.read { db in
                 poenger = try Poenger.join(Oppgaver.all) {$0.oppgaveId == $1.id}
                     .where{$1.proveId.eq(prøveId)}
                     .select {($0, $1.proveId)}
                     .fetchAll(db)
             }
         }
     }
     
     func hentOppgaverKategorierForProve() async {
         await withErrorReporting {
             try await database.read { db in
                 oppgaverKategorier = try OppgaverKategorier.join(Oppgaver.all) { $0.OppgaveId == $1.id }
                     .where{ $1.proveId.eq(prøveId) }
                     .select{($0, $1)}
                     .fetchAll(db)
             }
         }
     }
    
    func hentDeltakere() async {
        await withErrorReporting {
            try await database.read { db in
                deltakere = try Deltakere
                    .where{$0.proveId == self.prøveId}
                    .fetchAll(db)
            }
        }
    }
    
    func hentPrøve() async {
        await withErrorReporting {
            try await database.read { db in
                prøve = try Prover
                    .where{$0.id == prøveId}
                    .fetchOne(db)
            }
        }
    }
    
    func hentOppgaver() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaver = try Oppgaver
                    .where{$0.proveId == prøveId}
                    .fetchAll(db)
            }
        }
    }
    
    func hentKategorier() async {
        await withErrorReporting {
            try await database.read { db in
                kategorier = try Kategorier
                    .where{$0.proveId == prøveId}
                    .fetchAll(db)
            }
        }
    }
}

struct Stolpediagram: View {
    
    @Binding var prøve: Prover?
    @Binding var deltakere: [Deltakere]
    @Binding var oppgaver : [Oppgaver]
    @Binding var kategorier: [Kategorier]
    @Binding var poenger: [(Poenger, Prover.ID)]
    @Binding var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    @State var karakterer: [Karakter] = []
    
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
        .task {
            karakterer = await finnKarakterSammensetning()
        }
    }
                
        
    func finnKarakterSammensetning() async -> [Karakter] {
        let karaktergrenser = Testdata().karaktergrenser_test
        var karakterer:[Karakter]  = []
        for karakter in karaktergrenser.reversed() {
            if(karakterer.firstIndex(where: {$0.type == String(karakter.karakter[karakter.karakter.startIndex])}) == nil){
                karakterer.append(Karakter(type: String(karakter.karakter[karakter.karakter.startIndex]), count: 0))
            }
        }
        
        for deltaker in deltakere {
            for j in 0..<karakterer.count {
                let karakter =  karakterView(deltaker: deltaker, oppgaver: oppgaver, poenger: $poenger, indeks: 0, låstKarakter: Binding.constant(deltaker.låstKarakter)).finnKarakter()
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
    
    @Binding var prøve: Prover?
    @Binding var deltakere: [Deltakere]
    @Binding var oppgaver : [Oppgaver]
    @Binding var kategorier: [Kategorier]
    @Binding var poenger: [(Poenger, Prover.ID)]
    @Binding var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    
    let kategoriKolonner = [
        GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))]
    let farger: [Color] = [Color.teal, Color.red, Color.green, Color.indigo, Color.brown, Color.mint, Color.orange, Color.pink, Color.purple, Color.yellow, Color.gray, Color.cyan]
    @State var fargeNummer = 0
    
    var body: some View {
        LazyVGrid(columns: kategoriKolonner, spacing: 30) {
            ForEach(kategorier) { kategori in
                if(maxPoengKategori(kategori: kategori) > 0) {
                    VStack {
                        Text(kategori.navn)
                        kakediagram(desimaltall: Double(deltakerPoengKategori(kategori: kategori)/maxPoengKategori(kategori: kategori)), farge:farger[fargeNummer % farger.count])
                            .frame(width: 150, height: 150, alignment: .center)
                            .onAppear {
                                fargeNummer += 1
                            }
                        Text(String(deltakerPoengKategori(kategori: kategori)) + "/" + String(maxPoengKategori(kategori: kategori)))
                    }
                }
            }
        }
    }
    
    func deltakerPoengKategori(kategori: Kategorier) -> Double {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        var sum: Double = 0
        var antall: Double = 0
        for deltaker in deltakere {
            for oppgave in oppgaver {
                if(oppgaverKategorier.contains(where: {$0.0.KategoriId == kategori.id && $0.0.OppgaveId == oppgave.id})){
                    let poengSomString = poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0.poeng ?? ""
                    if let poengSomTall = formatter.number(from: poengSomString) {
                        sum += poengSomTall.doubleValue
                        antall += 1
                    }
                }
            }
        }
        return (sum/antall)
    }
    
    func deltakerHarLevert(deltaker: Deltakere) -> Bool {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        for poeng in poenger {
            if(poeng.0.deltakerId == deltaker.id) {
                if (formatter.number(from: poeng.0.poeng) != nil)  {
                    return true
                }
            }
        }
        return false
    }
    
    func maxPoengKategori(kategori: Kategorier) -> Double {
        var sum: Double = 0
        for oppgavekategori in oppgaverKategorier {
            if(oppgavekategori.0.KategoriId == kategori.id) {
                sum += oppgavekategori.1.maksPoeng ?? 0
            }
        }
        return sum
    }
}
