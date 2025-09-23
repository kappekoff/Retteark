//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI
import SharingGRDB

struct elevTilbakemeldingVisning: View {
    @Dependency(\.defaultDatabase) var database

    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
    var lagerPDF: Bool = false
    
    var deltakerId: Deltakere.ID
    var prøveId: Prover.ID
    @State var deltaker: Deltakere? = nil
    @State var prøve: Prover? = nil
    @State var oppgaver : [Oppgaver] = []
    @State var kategorier: [Kategorier] = []

    
    var body: some View {

        ScrollView {
            if let deltaker = deltaker, let prøve = prøve {
                top(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, visElevTilbakemleding: $visElevTilbakemleding)
                hovedinnhold(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, visElevTilbakemleding: $visElevTilbakemleding,  lagerPDF: false)
            }
            else {
                Text("Fant ikke elev/prøve")
            }
          
        }
        Button("Lukk") {
            visElevTilbakemleding = nil
        }
    }
    
    func hentDeltaker() async {
        await withErrorReporting {
            try await database.read { db in
                deltaker = try Deltakere
                    .where{$0.id == deltakerId}
                    .fetchOne(db)
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

struct top: View {
    @Dependency(\.defaultDatabase) var database
    var deltaker: Deltakere
    var prøve: Prover
    var oppgaver : [Oppgaver]
    var kategorier: [Kategorier]
    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
    @State var visFilvelger = false
  
    var body: some View {
        HStack {
            Text(deltaker.navn).font(.largeTitle).frame(alignment: .center)
            Button {
                visFilvelger.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up.circle.fill")
            }
            .fileExporter(isPresented: $visFilvelger, document: PDFDocument(pdfData: Data()), contentType: .pdf, defaultFilename: "\(prøve.navn)_\(deltaker.navn).pdf") { result in
                switch result {
                case .success(let file):
                    lagPDF(innhold: VStack {
                        top(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, visElevTilbakemleding: $visElevTilbakemleding)
                        hovedinnhold(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, visElevTilbakemleding: $visElevTilbakemleding, lagerPDF: true)
                    }, filplassering: file)
                case .failure(let error):
                    print(error)
                }
            }
            
        }
    }
}

struct hovedinnhold: View {
    @Dependency(\.defaultDatabase) var database
    var deltaker: Deltakere
    var prøve: Prover
    var oppgaver : [Oppgaver]
    var kategorier: [Kategorier]
    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
  
    var lagerPDF: Bool = false
    @State var fargeIndex: Int = 0
    @State var poenger: [(Poenger, Prover.ID)] = []
    @State var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)] = []
    @State var framovermelding: String = ""
    let kategoriKolonner = [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))]
    let poengKolonner = [GridItem(.flexible(minimum: 50), spacing: 0),GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0),GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0),GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0)]
  
    let farger: [Color] = [Color.teal, Color.red, Color.green, Color.indigo, Color.brown, Color.mint, Color.orange, Color.pink, Color.purple, Color.yellow, Color.gray, Color.cyan]
    
    var body: some View {
        VStack(alignment: .listRowSeparatorLeading){
            LazyVGrid(columns: poengKolonner, alignment: .leading, spacing: 15) {
                ForEach(oppgaver) { oppgave in
                    VStack(spacing: 0) {
                        Text(oppgave.navn)
                            .frame(width: 50, height: 20, alignment: .center)
                            .background(.green)
                            .border(.primary)
                            .fontWeight(.bold)
                        Text(String(oppgave.maksPoeng ?? -1))
                            .frame(width: 50, height: 20, alignment: .center)
                            .border(.primary)
                            .background(.orange)
                        Text(poenger.first(where: {$0.0.oppgaveId == oppgave.id})?.0.poeng ?? "???")
                            .frame(width: 50, height: 20, alignment: .center)
                            .border(.primary)
                    }
                }
                LazyVGrid(columns: kategoriKolonner, spacing: 30) {
                    ForEach(kategorier) { kategori in
                        if(oppgaverKategorier.contains(where: {$0.0.KategoriId == kategori.id})) {
                            VStack {
                                Text(kategori.navn)
                                kakediagram(desimaltall: kategoriDetakerPoeng(kategori: kategori)/kategoriMaxPoeng(kategori: kategori), farge:farger[fargeIndex])
                                    .frame(width: 150, height: 150, alignment: .center)
                                    .onAppear {
                                        fargeIndex += 1
                                        fargeIndex  %= farger.count
                                    }
                                Text(String(kategoriDetakerPoeng(kategori: kategori)) + "/" + String(kategoriMaxPoeng(kategori: kategori)))
                            }
                        }
                    }
                }
                
                Text(.init(lagElevtilbakemelding())).frame(alignment: .leading)
                
                if(lagerPDF) {
                    Text(deltaker.framovermelding)
                }
                else {
                    TextField("Framovermelding", text: $framovermelding, axis: .vertical)
                        .onAppear {
                            framovermelding = deltaker.framovermelding
                        }
                        .onChange(of: framovermelding) {
                            Task {
                                await withErrorReporting {
                                    try await database.write { db in
                                        var midlertidiDeltaker = deltaker
                                        midlertidiDeltaker.framovermelding = framovermelding
                                        try Deltakere.update(midlertidiDeltaker).execute(db)
                                        
                                    }
                                }
                            }
                        }
                }
                
                if(prøve.visEleverKarakter){
                    karakterView(prøveId: prøve.id, deltakerId: deltaker.id, indeks: 0, låstKarakter: Binding.constant(deltaker.låstKarakter), endretPoeng: Binding.constant(0)
                    )
                }
                
            }.padding(20).frame(width: 500)
        }
    }
    
    
   func hentPoenger() async {
       let q1 = Poenger.join(Oppgaver.all) {$0.oppgaveId == $1.id}
       let q2 = q1.where{$0.deltakerId == self.deltaker.id && $1.proveId == self.prøve.id}
       let q3 = q2.select {($0, $1.proveId)}
        await withErrorReporting {
            try await database.read { db in
                poenger = try q3
                    .fetchAll(db)
            }
        }
    }
    
    func hentOppgaverKategorierForProve() async {
        let q1 = OppgaverKategorier.join(Oppgaver.all) { $0.OppgaveId == $1.id }
        let q2 = q1.where{ $1.proveId == self.prøve.id }
        let q3 = q2.select{($0, $1)}
        await withErrorReporting {
            try await database.read { db in
                oppgaverKategorier = try q3
                    .fetchAll(db)
            }
        }
    }
    
    func kategoriMaxPoeng(kategori: Kategorier) -> Double {
        var sum: Double = 0
        for oppgave in oppgaver {
            if(oppgaverKategorier.contains(where: {$0.0.KategoriId == kategori.id && $0.0.OppgaveId == oppgave.id})) {
                if let maksPoeng = oppgave.maksPoeng {
                    sum += maksPoeng
                }
            }
        }
        return sum
    }
        
    func kategoriDetakerPoeng(kategori: Kategorier) -> Double {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        var sum: Double = 0
        for oppgave in oppgaver {
            if(oppgaverKategorier.contains(where: {$0.0.KategoriId == kategori.id && $0.0.OppgaveId == oppgave.id})) {
                if let maksPoengString = poenger.first(where: {$0.0.oppgaveId == oppgave.id})?.0.poeng{
                    if let maksPoeng = formatter.number(from: maksPoengString) as? Double {
                        sum += maksPoeng
                    }
                }
            }
        }
        return sum
    }
  
  func lagElevtilbakemelding() -> String {
      let tilbakemeldinger = Testdata().tilbakemeldinger
      var høy: String = "**" + tilbakemeldinger[0].tekst + ":** "
      var middels: String = "**" + tilbakemeldinger[1].tekst + ":** "
      var lav: String = "**" + tilbakemeldinger[2].tekst + ":** "
      var taMedHøy: Bool = false
      var taMedMiddels: Bool = false
      var taMedLav: Bool = false
      for kategori in kategorier {
          if(kategoriDetakerPoeng(kategori: kategori)/kategoriMaxPoeng(kategori: kategori) > (tilbakemeldinger[0].nedreGrense ?? 66) / 100) {
                  høy += kategori.navn + ", "
                  taMedHøy = true
          }
              
          else if(kategoriDetakerPoeng(kategori: kategori)/kategoriMaxPoeng(kategori: kategori) > (tilbakemeldinger[1].nedreGrense ?? 33) / 100) {
                  middels += kategori.navn + ", "
                  taMedMiddels = true
          }
          else if(kategoriDetakerPoeng(kategori: kategori)/kategoriMaxPoeng(kategori: kategori) > (tilbakemeldinger[2].nedreGrense ?? 0)/100) {
                  lav += kategori.navn + ", "
                  taMedLav = true
          }
      }
      
      middels = String(middels.dropLast(2))
      middels += "\n \n"
      høy = String(høy.dropLast(2))
      høy += "\n \n"
      lav = String(lav.dropLast(2))
      lav += "\n"
      
      var tilbakemelding: String = ""
      if(taMedHøy) {
          tilbakemelding += høy
      }
      if(taMedMiddels) {
          tilbakemelding += middels
      }
      if(taMedLav) {
          tilbakemelding += lav
      }
      return tilbakemelding
  }
}
