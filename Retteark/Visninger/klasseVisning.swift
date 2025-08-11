//
//  klasseVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import SwiftUI
import SharingGRDB

@Observable
class KlasseVisningModell {
    @ObservationIgnored @Dependency(\.defaultDatabase) var database
    @ObservationIgnored @SharedReader(.fetchAll(sql: "SELECT * FROM klasser")) var klasser: [Klasser]
    @ObservationIgnored @FetchAll var prøver: [Prover] = []
    
    func hentProverForKlasse(klasseId: String) async {
        await withErrorReporting {
            try await $prøver.load(
                Prover
                    .where{ $0.klasseId == klasseId },
                animation: .default
            )
        }
        
    }
}



struct klasseVisning: View {
    
    @Environment(Klasseoversikt.self) var klasseoversikt
    @State private var visSideKolonner = NavigationSplitViewVisibility.all
    @State private var valgtKlasseID: Klasse.ID?
    @State private var valgtPrøveID: Prøve.ID?
    @State var visKlassevisningSheet: VisKlassevisningSheet? = nil
    
    @Dependency(\.defaultDatabase) var database
    @SharedReader(.fetchAll(sql: "SELECT * FROM Klasser")) var klasser: [Klasser]
    @FetchAll var prøver: [Prover] = []

    var body: some View {
        @Bindable var klasseoversikt = klasseoversikt
        NavigationSplitView(columnVisibility: $visSideKolonner){
           List(selection: $valgtKlasseID) {
                ForEach(klasser){ valgtKlasse in
                    HStack {
                        Text(valgtKlasse.navn)
                        Spacer()
                        Text(valgtKlasse.skoleår)
                    }
                    .font(.title).bold()
                    /*.swipeActions {
                        Button(role: .destructive) {
                            slettKlasseFraListe(klasse: valgtKlasse)
                            print("Slett Klasse")
                        } label: {
                            Image(systemName: "trash")
                        }
                        
                        Button {
                            visKlassevisningSheet = .redigerKlasse(klasseid: valgtKlasse.wrappedValue.id)
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .tint(.yellow)
                    }*/
                }
                //.onDelete(perform: funksjonSomIkkeSletterNoe)
           }
            .navigationTitle("Klasser")
            .toolbar(content: {
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
                
                ToolbarItem(placement: .bottomBar) {
                    Text(.init("**Sist lagret:** " + (klasseoversikt.klasseinformasjon.lagret_tidspunkt?.formatted() ?? "")))
                }
                
            })
            .toolbar(removing: .sidebarToggle)
            
        } content:{
            if let valgtKlasseID = valgtKlasseID, let valgtKlasse=klasseoversikt.klasseFraId(id: valgtKlasseID) {
                List(selection: $valgtPrøveID) {
                    ForEach(valgtKlasse.prøver){ valgtPrøve in
                        Text(valgtPrøve.navn).font(.title).bold()
                            .swipeActions {
                                Button(role: .destructive) {
                                    print("Slett prøve")
                                    slettPrøveFraKlasse(prøve: valgtPrøve)
                                } label: {
                                    Image(systemName: "trash")
                                }

                                Button {
                                    print("Rediger prøve")
                                    visKlassevisningSheet = .redigerPrøve(klasseid: valgtKlasse.id, prøveid: valgtPrøve.id)
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .tint(.yellow)

                            }
                    }
                    .onDelete(perform: funksjonSomIkkeSletterNoe)
                }
                .navigationTitle("Prøver")
                .toolbar(content: {
                    EditButton()
                    Button {
                        visKlassevisningSheet = .leggTilPrøve
                    } label: {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                    }
                })
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
        .onAppear {
            print(klasser)
        }
        .fullScreenCover(item: $visKlassevisningSheet, onDismiss: {visKlassevisningSheet = nil}) { visKlassevisningSheet in
            switch visKlassevisningSheet {
            case .leggTilKlasse:
                leggTilNyKlasseVisning(tekstFraVisma: "", klasseNavn: "", skoleÅr: "",  visKlassevisningSheet: $visKlassevisningSheet).environment(klasseoversikt)
            case .leggTilPrøve:
                if let valgtKlasseID = valgtKlasseID {
                    leggTilNyPr_veVisning(KlasseID: valgtKlasseID,  visKlassevisningSheet: $visKlassevisningSheet).environment(klasseoversikt)
                }
            case .redigerKlasse(let klasseid):
                redigerKlasse(klasseId: klasseid, visKlassevisningSheet: $visKlassevisningSheet).environment(klasseoversikt)
            case .redigerPrøve(let klasseid, let prøveid):
                redigerPr_ve(prøveId: prøveid, klasseId: klasseid, visKlassevisningSheet: $visKlassevisningSheet).environment(klasseoversikt)
                
            }
        }
    }
    
    func slettKlasseFraListe(klasse: Klasse){
        if let indeks = klasseoversikt.klasseinformasjon.klasser.firstIndex(where: {$0.id == valgtKlasseID}) {
            klasseoversikt.klasseinformasjon.klasser.remove(at: indeks)
        }
    }
    
    func slettPrøveFraKlasse(prøve: Prøve){
        if let valgtKlasseID = valgtKlasseID {
            if let klasseIndeks = klasseoversikt.klasseinformasjon.klasser.firstIndex(where: {$0.id == valgtKlasseID}) {
                if let prøveIndeks = klasseoversikt.klasseinformasjon.klasser[klasseIndeks].prøver.firstIndex(where: {$0.id == prøve.id}) {
                    klasseoversikt.klasseinformasjon.klasser[klasseIndeks].prøver.remove(at: prøveIndeks)
                }
                    
            }
            
            
        }
    }
    
    func funksjonSomIkkeSletterNoe(at indeksset: IndexSet) {
        print("funksjonSomIkkeSletterNoe: Ingen skal noen gang komme hit. Hva gjør du her?")
    }
}

