//
//  klasseVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import SwiftUI
import SharingGRDB

struct klasseVisning: View {
    
    @State private var visSideKolonner = NavigationSplitViewVisibility.all
    @State private var valgtKlasseID: Klasser.ID?
    @State private var valgtPrøveID: Prover.ID?
    @State var visKlassevisningSheet: VisKlassevisningSheet? = nil
    
    @Dependency(\.defaultDatabase) var database
    @SharedReader(.fetchAll(sql: "SELECT * FROM Klasser")) var klasser: [Klasser]
    @FetchAll var prøver: [Prover] = []

    var body: some View {
        NavigationSplitView(columnVisibility: $visSideKolonner){
           List(selection: $valgtKlasseID) {
                ForEach(klasser){ valgtKlasse in
                    HStack {
                        Text(valgtKlasse.navn)
                        Spacer()
                        Text(valgtKlasse.skoleår)
                    }
                    .font(.title)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await slettKlasseFraListe(klasse: valgtKlasse)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        
                        Button {
                            visKlassevisningSheet = .redigerKlasse(klasseid: valgtKlasse.id)
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .tint(.yellow)
                    }
                }
                .onDelete(perform: funksjonSomIkkeSletterNoe)
           }
            .navigationTitle("Klasser")
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        visKlassevisningSheet = .leggTilKlasse
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                }
            }
            .toolbar(removing: .sidebarToggle)
            }content:{
            if (valgtKlasseID != nil) {
                List(selection: $valgtPrøveID) {
                    ForEach(prøver){ valgtPrøve in
                        Text(valgtPrøve.navn).font(.title2)
                            .swipeActions {
                                Button {
                                    Task {
                                        await slettPrøveFraKlasse(prøve: valgtPrøve)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                                Button {
                                    visKlassevisningSheet = .redigerPrøve(prøveid: valgtPrøve.id)
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .tint(.yellow)

                            }
                    }
                    .onDelete(perform: funksjonSomIkkeSletterNoe)
                }
                .navigationTitle("Prøver")
                .toolbar{
                    ToolbarItem(placement: .primaryAction) {
                        EditButton()
                    }
                    ToolbarItem(placement: .principal) {
                        Button {
                            visKlassevisningSheet = .leggTilPrøve
                        } label: {
                            Image(systemName: "plus.circle").foregroundColor(.green)
                        }
                    }
                }
            }
            else {
                Text("Velg klasse")
            }
        } detail: {
            VStack {
                HStack {
                    Button {
                        if(visSideKolonner == .all) {
                            visSideKolonner = .detailOnly
                        }
                        else if(visSideKolonner == .detailOnly) {
                            visSideKolonner = .all
                        }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.title2)
                    }
                    Spacer()
                }
                ContentView(valgtKlasseID: valgtKlasseID, valgtPrøveID: valgtPrøveID)
                Spacer()
            }
            
        }
        .onChange(of: valgtKlasseID) {
            Task {
                await hentProverForKlasse()
            }
        }
        .fullScreenCover(item: $visKlassevisningSheet, onDismiss: {visKlassevisningSheet = nil}) { visKlassevisningSheet in
            switch visKlassevisningSheet {
            case .leggTilKlasse:
                leggTilNyKlasseVisning(tekstFraVisma: "", klasseNavn: "", skoleÅr: "",  visKlassevisningSheet: $visKlassevisningSheet)
            case .leggTilPrøve:
                if let valgtKlasseID = valgtKlasseID {
                    leggTilNyPr_veVisning(klasseID: valgtKlasseID,  visKlassevisningSheet: $visKlassevisningSheet)
                }
            case .redigerKlasse(let klasseid):
                redigerKlasse(valgtKlasseID: klasseid, visKlassevisningSheet: $visKlassevisningSheet)
            case .redigerPrøve( let prøveid):
                redigerPr_ve(prøveId: prøveid, visKlassevisningSheet: $visKlassevisningSheet)
                
            }
        }
    }
    
    func slettKlasseFraListe(klasse: Klasser) async {
        let midlertidigKlasse = klasser.first(where: {$0.id == klasse.id}) ?? Klasser(id: klasse.id, navn: klasse.navn, skoleår: klasse.skoleår)
        await withErrorReporting {
            try await database.write { db in
                try Klasser.delete(midlertidigKlasse).execute(db)
            }
        }
    }
    
    func slettPrøveFraKlasse(prøve: Prover) async {
        let midlertidigPrøve = prøver.first(where: {$0.id == prøve.id}) ?? Prover(id: prøve.id, navn: prøve.navn, visEleverKarakter: prøve.visEleverKarakter, klasseId: prøve.klasseId)
        await withErrorReporting {
            try await database.write { db in
                try Prover.delete(midlertidigPrøve).execute(db)
            }
        }
    }
    
    func funksjonSomIkkeSletterNoe(at indeksset: IndexSet) {
        print("funksjonSomIkkeSletterNoe: Ingen skal noen gang komme hit. Hva gjør du her?")
    }
    
    func hentProverForKlasse() async {
        await withErrorReporting {
            try await $prøver.load(
                Prover
                    .where{ $0.klasseId == self.valgtKlasseID },
                animation: .default
            )
        }
        
    }
}

