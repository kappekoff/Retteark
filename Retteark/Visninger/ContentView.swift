//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(Klasseoversikt.self) var klasseoversikt
    var valgtKlasseID: Klasse.ID?
    var valgtPrøveID: Prøve.ID?
    @State var viserSheet: VisElevTilbakemleding? = nil
    @State var visFilvelger: Bool = false
  
    
    var body: some View {
        @Bindable var klasseoversikt = klasseoversikt
        if let valgtKlasseID = valgtKlasseID {
            if let valgtPrøveID = valgtPrøveID, let valgtKlasse = klasseoversikt.klasseFraId(id: valgtKlasseID), let valgtPrøve = valgtKlasse.finnPrøveFraId(id: valgtPrøveID) {
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
                        Button {
                          visFilvelger.toggle()
                        } label: {
                          Image(systemName: "square.and.arrow.up.circle.fill")
                        }
                        .fileExporter(isPresented: $visFilvelger, documents: [PDFDocument(pdfData: Data())], contentType: .directory) { result in
                          switch result {
                           case .success(let file):
                            let dataPath = file.first!.deletingLastPathComponent().appendingPathComponent("\(file.first!.deletingPathExtension().lastPathComponent)")
                            do {
                              try FileManager.default.removeItem(at: file.first!)
                              
                              print(dataPath.path)
                              try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                            } catch {
                                print(error.localizedDescription)
                            }
                            for elev in valgtPrøve.elever {
                              lagPDF(innhold:VStack {
                                top(elev: elev, prøve: valgtPrøve, visElevTilbakemleding: $viserSheet)
                                hovedinnhold(elev: elev, visElevTilbakemleding: $viserSheet , prøve: valgtPrøve, lagerPDF: true)
                              }, filplassering: dataPath.appendingPathComponent("\(valgtPrøve.navn)_\(elev.navn).pdf", conformingTo: .pdf))
                            }
                           case .failure(let error):
                            print(error)
                         }
                       }

                        .keyboardShortcut("p")
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
                            kategoriView(viserSheet: $viserSheet, prøve: valgtPrøve)
                        case .velgtInstillinger:
                            instillinger(prøve: valgtPrøve, visElevTilbakemleding: $viserSheet)
                        case .velgtKlassesammendrag:
                            Klassesammendrag(visElevTilbakemleding: $viserSheet, prøve: valgtPrøve)
                                .presentationDetents([.large])
                        default:
                            Text("Du skal aldri komme hit")
                        }
                    }
                    ScrollView(.horizontal) {
                        poengTabellView(prøve: valgtPrøve)
                            .padding([.bottom, .leading, .trailing])
                    }
                    
                }
            }
            else {
                Text("Velg prøve")
            }
        }
        
        
    }
}
