//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var klasseoversikt:Klasseoversikt
    var valgtKlasseID: Klasse.ID?
    var valgtPrøveID: Prøve.ID?
    @State var viserSheet: VisElevTilbakemleding? = nil
    @State var viserAlert: Bool = false
    
    var body: some View {
        if let valgtPrøveID = valgtPrøveID, let valgtKlasse = klasseoversikt.klasseFraId(id: valgtKlasseID!), let $valgtPrøve = valgtKlasse.finnPrøveFraId(id: valgtPrøveID) {
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
                    Button(action: {
                        let docuementDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                        let dataPath = docuementDirectory.appendingPathComponent("\($valgtPrøve.navn)")
                        if !FileManager.default.fileExists(atPath: dataPath.path) {
                            do {
                                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        for elev in $valgtPrøve.elever {
                            let outputfileURL: URL? = dataPath.appendingPathComponent("\($valgtPrøve.navn) \(elev.navn).pdf")
                            exportPDF(outputfileURL: outputfileURL){
                                elevTilbakemeldingVisning(elev: elev, visElevTilbakemleding: $viserSheet , prøve: $valgtPrøve)
                            } completion: { status, url in
                                if let url = url,status{
                                    print(url)
                                }
                                else {
                                    print("Klarte ikke produsere pdf")
                                }
                            }
                        }
                        viserAlert = true
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                    .keyboardShortcut("p")
                    .alert("Se nedlastinger for pdfene", isPresented: $viserAlert) {
                                Button("OK", role: .cancel) { }
                            }
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
                        kategoriView(viserSheet: $viserSheet, prøve: $valgtPrøve)
                    case .velgtInstillinger:
                        instillinger(prøve: $valgtPrøve, visElevTilbakemleding: $viserSheet)
                    case .velgtKlassesammendrag:
                        Klassesammendrag(visElevTilbakemleding: $viserSheet, prøve: $valgtPrøve)
                            .presentationDetents([.large])
                    default:
                        Text("Du skal aldri komme hit")
                    }
                }
                ScrollView(.horizontal) {
                    poengTabellView(prøve: $valgtPrøve)
                        .onChange(of: valgtPrøveID) { _ in
                            klasseoversikt.lagreKlasser()
                        }
                        .onDisappear {
                            klasseoversikt.lagreKlasser()
                        }                    
                }
                
            }
        }
        else {
            Text("Velg prøve")
        }
        
    }
}
