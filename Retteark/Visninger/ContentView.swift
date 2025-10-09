//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI
import SharingGRDB


struct ContentView: View {
    
    @Environment(Klasseoversikt.self) var klasseoversikt
    @Dependency(\.defaultDatabase) var database
    var valgtKlasseID: Klasse.ID?
    var valgtPrøveID: Prøve.ID?
    
    @State var valgtKlasse: Klasser? = nil
    @State var valgtPrøve: Prover? = nil
    @State var proveDeltakere: [Elever] = []
    
    @State var viserSheet: VisElevTilbakemleding? = nil
    @State var visFilvelger: Bool = false
    @State var tilbakemledingerLaget: Double = 0.0
  
    
    var body: some View {
        @Bindable var klasseoversikt = klasseoversikt
        if let valgtKlasseID = valgtKlasseID {
            if let valgtPrøveID = valgtPrøveID {
                VStack {
                    HStack {
                        Button(action: {
                            viserSheet = .valgtKategorier
                            
                        }, label: {
                            Image(systemName: "squareshape.split.3x3")
                        })
                        .keyboardShortcut("k")
                        Button(action: {
                            viserSheet = .velgtInstillinger
                            
                        }, label: {
                            Image(systemName: "gear")
                        })
                        .keyboardShortcut("i")
                        Button(action: {
                            klasseoversikt.lagreKlasser()
                        }, label: {
                            Image(systemName: "square.and.arrow.down")
                        })
                        .keyboardShortcut("s")
                        /*Button {
                          visFilvelger.toggle()
                        } label: {
                          Image(systemName: "square.and.arrow.up.circle.fill")
                        }
                        .fileExporter(isPresented: $visFilvelger, documents: [PDFDocument(pdfData: Data())], contentType: .directory) { result in
                          switch result {
                           case .success(let file):
                            viserSheet = .viserProgressView
                            let dataPath = file.first!.deletingLastPathComponent().appendingPathComponent("\(file.first!.deletingPathExtension().lastPathComponent)")
                            do {
                              try FileManager.default.removeItem(at: file.first!)
                              try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                            } catch {
                                print(error.localizedDescription)
                            }
                            tilbakemledingerLaget = 0
                            
                            for deltaker in proveDeltakere {
                              lagPDF(innhold:VStack {
                                top(elev: elev, prøve: valgtPrøve, visElevTilbakemleding: $viserSheet)
                                hovedinnhold(elev: elev, visElevTilbakemleding: $viserSheet , prøve: valgtPrøve, lagerPDF: true)
                              }, filplassering: dataPath.appendingPathComponent("\(valgtPrøve.navn)_\(elev.navn).pdf", conformingTo: .pdf))
                              tilbakemledingerLaget = Double(1/valgtPrøve.elever.count)
                            }
                            viserSheet = nil
                           case .failure(let error):
                            print(error)
                         }
                       }*/
                        Button(action: {
                            viserSheet = .velgtKlassesammendrag
                            
                        }, label: {
                            Image(systemName: "chart.bar.xaxis")
                        })
                        .keyboardShortcut("p")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    .fullScreenCover(item: $viserSheet, onDismiss: {viserSheet = nil}){ viserSheet in
                        switch viserSheet{
                        case .valgtKategorier:
                            kategoriView(viserSheet: $viserSheet, valgtPrøveID: valgtPrøveID).environment(klasseoversikt)
                        case .velgtInstillinger:
                            instillinger(valgtPrøveID: valgtPrøveID, visElevTilbakemleding: $viserSheet).environment(klasseoversikt)
                        case .velgtKlassesammendrag:
                            Klassesammendrag(visElevTilbakemleding: $viserSheet, prøveId: valgtPrøveID)
                        case .viserProgressView:
                            ProgressView("Lagrer tilbakemeldinger", value: tilbakemledingerLaget)
                              .progressViewStyle(.circular)
                            
                        default:
                            Text("Du skal aldri komme hit")
                        }
                    }
                    ScrollView(.horizontal) {
                        poengTabellView(prøveID: valgtPrøveID)
                            .padding([.bottom, .leading, .trailing])
                    }
                    
                }
                .task {
                    await hentKlasse()
                    await hentPrøve()
                }
            }
            else {
                Text("Velg prøve")
            }
        }
    }
    
    func hentKlasse() async {
        await withErrorReporting {
            try await database.read { db in
                valgtKlasse = try Klasser
                    .where { $0.id == self.valgtKlasseID}
                    .fetchOne(db)
            }
        }
    }
    
    func hentPrøve() async {
        await withErrorReporting {
            try await database.read { db in
                valgtPrøve = try Prover
                    .where { $0.id == self.valgtPrøveID}
                    .fetchOne(db)
            }
        }
    }
}
