//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI
import SQLiteData

struct elevTilbakemeldingVisning: View {

    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
    var lagerPDF: Bool = false
    
    var deltaker: Deltakere
    var prøve: Prover
    @Binding var oppgaver : [Oppgaver]
    @Binding var kategorier: [Kategorier]
    @Binding var poenger: [(Poenger, Prover.ID)]
    @Binding var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    
    var body: some View {

        ScrollView {
            VStack {
                top(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier,poenger: $poenger, oppgaverKategorier: oppgaverKategorier, visElevTilbakemleding: $visElevTilbakemleding)
                hovedinnhold(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, poenger: $poenger, oppgaverKategorier: oppgaverKategorier, visElevTilbakemleding: $visElevTilbakemleding,  lagerPDF: false)
            }
        }
        Button("Lukk") {
            visElevTilbakemleding = nil
        }
    }
}

struct top: View {
    @Dependency(\.defaultDatabase) var database
    var deltaker: Deltakere
    var prøve: Prover
    var oppgaver : [Oppgaver]
    var kategorier: [Kategorier]
    @Binding var poenger: [(Poenger, Prover.ID)]
    var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
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
                        top(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier,poenger: $poenger, oppgaverKategorier: oppgaverKategorier, visElevTilbakemleding: $visElevTilbakemleding)
                        hovedinnhold(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, poenger: $poenger, oppgaverKategorier: oppgaverKategorier, visElevTilbakemleding: $visElevTilbakemleding, lagerPDF: true)
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
    @Binding var poenger: [(Poenger, Prover.ID)]
    var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)]
    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
  
    var lagerPDF: Bool = false

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
                        Text(poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0.poeng ?? "???")
                            .frame(width: 50, height: 20, alignment: .center)
                            .border(.primary)
                    }
                }
            }
            LazyVGrid(columns: kategoriKolonner, spacing: 30) {
                ForEach(Array(kategorier.filter({$0.proveId == prøve.id}).enumerated()), id: \.element.id) { kategoriIndex, kategori in
                    if(oppgaverKategorier.contains(where: {$0.0.KategoriId == kategori.id})) {
                        VStack {
                            Text(kategori.navn)
                            kakediagram(desimaltall: kategoriDetakerPoeng(kategori: kategori)/kategoriMaxPoeng(kategori: kategori), farge:farger[kategoriIndex % farger.count])
                                    .frame(width: 150, height: 150, alignment: .center)
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
                HStack {
                    Text("Karakter: ")
                    karakterView(deltaker: deltaker, oppgaver: oppgaver, poenger: $poenger, indeks: 1, låstKarakter: Binding.constant(deltaker.låstKarakter), lagerPDF: lagerPDF)
                }
            }
                
        }
        .padding(20)
        .frame(maxWidth: 500, maxHeight: .infinity)

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
                if let maksPoengString = poenger.first(where: {$0.0.oppgaveId == oppgave.id && $0.0.deltakerId == deltaker.id})?.0.poeng{
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
