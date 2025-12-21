//
//  ContentView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI
import SQLiteData


struct ContentView: View {
    @Dependency(\.defaultDatabase) var database
    var valgtKlasseID: Klasser.ID?
    var valgtPrøveID: Prover.ID?
    
    @State var valgtKlasse: Klasser? = nil
    @State var valgtPrøve: Prover? = nil
    
    @State var prøve: Prover? = nil
    @State var oppgaver: [Oppgaver] = []
    @State var deltakere: [Deltakere] = []
    @State var poenger: [(Poenger, Prover.ID)] = []
    @State var kategorier: [Kategorier] = []
    @State var oppgaverKategorier: [(OppgaverKategorier, Oppgaver)] = []
    
    @State var viserSheet: VisElevTilbakemleding? = nil
    @State var visFilvelger: Bool = false
    @State var tilbakemledingerLaget: Double = 0.0
    
    
    var body: some View {
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
                            viserSheet = .velgtInstillinger(proveID: valgtPrøveID)
                            
                        }, label: {
                            Image(systemName: "gear")
                        })
                        .keyboardShortcut("i")
                        Button {
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
                             for deltaker in deltakere {
                                 if let prøve = prøve {
                                     lagPDF(innhold: VStack {
                                         Text(deltaker.navn).font(.largeTitle)
                                         hovedinnhold(deltaker: deltaker, prøve: prøve, oppgaver: oppgaver, kategorier: kategorier, poenger: $poenger, oppgaverKategorier: oppgaverKategorier, visElevTilbakemleding: Binding.constant(.valgtElev(deltaker: deltaker)), lagerPDF: true)
                                     }, filplassering: dataPath.appendingPathComponent("\(prøve.navn)_\(deltaker.navn).pdf", conformingTo: .pdf))
                                 }
                             }
                             viserSheet = nil
                             case .failure(let error):
                             print(error)
                             }
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
                            kategoriView(viserSheet: $viserSheet, valgtPrøveID: valgtPrøveID,oppgaver: $oppgaver, kategorier: $kategorier, oppgaverKategorier: $oppgaverKategorier)
                        case .velgtInstillinger:
                            instillinger(prøve: $prøve, oppgaver: $oppgaver, deltakere: $deltakere, kategorier: $kategorier, visElevTilbakemleding: $viserSheet)
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
                        poengTabellView(prøve: $prøve, oppgaver: $oppgaver, deltakere: $deltakere, poenger: $poenger, kategorier: $kategorier, oppgaverKategorier: $oppgaverKategorier)
                            .padding([.bottom, .leading, .trailing])
                        
                    }
                    
                }
                .task {
                    await hentPrøve()
                    await hentOppgaver()
                    await hentDeltakere()
                    await hentPoenger()
                    await hentKategorier()
                    await hentOppgaverKategorierForProve()
                }
                .onChange(of: valgtPrøveID)  {
                    Task {
                        await hentPrøve()
                        await hentOppgaver()
                        await hentDeltakere()
                        await hentPoenger()
                        await hentKategorier()
                        await hentOppgaverKategorierForProve()
                    }
                    
                }
            }
            else {
                Text("Velg prøve")
            }
        }
    }
    
    func hentPrøve() async {
        await withErrorReporting {
            try await database.read { db in
                prøve = try Prover
                    .where { $0.id == self.valgtPrøveID}
                    .fetchOne(db)
            }
        }
    }
    
    func hentOppgaver() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaver = try Oppgaver
                    .where { $0.proveId == self.valgtPrøveID}
                    .fetchAll(db)
            }
        }
    }
    
    func hentDeltakere() async {
        await withErrorReporting {
            try await database.read { db in
                deltakere = try Deltakere
                    .where { $0.proveId == self.valgtPrøveID}
                    .order(by: {$0.navn.lower()})
                    .fetchAll(db)
            }
        }
    }
    
    func hentPoenger() async {
        await withErrorReporting {
            try await database.read { db in
                poenger = try Poenger.join(Oppgaver.all) {$0.oppgaveId == $1.id}
                    .where{$1.proveId.eq(valgtPrøveID ?? "ingenvalgtPRøveID")}
                    .select {($0, $1.proveId)}
                    .fetchAll(db)
            }
        }
    }
    
    func hentOppgaverKategorierForProve() async {
        await withErrorReporting {
            try await database.read { db in
                oppgaverKategorier = try OppgaverKategorier.join(Oppgaver.all) { $0.OppgaveId == $1.id }
                    .where{ $1.proveId.eq(valgtPrøveID ?? "ingenvalgtPRøveID") }
                    .select{($0, $1)}
                    .fetchAll(db)
            }
        }
    }
   
   
   func hentKategorier() async {
       await withErrorReporting {
           try await database.read { db in
               kategorier = try Kategorier
                   .where{$0.proveId == valgtPrøveID ?? "ingenvalgtPRøveID"}
                   .fetchAll(db)
           }
       }
   }
    
}
