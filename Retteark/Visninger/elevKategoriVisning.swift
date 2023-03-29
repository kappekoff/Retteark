//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI

struct elevTilbakemeldingVisning: View {
    var elev: Elev
    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
    @ObservedObject var prøve: Prøve
    
    let kategoriKolonner = [
        GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))
        ]
    let poengKolonner = [GridItem(.flexible(minimum: 50), spacing: 0),GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0),GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0),GridItem(.flexible(minimum: 50), spacing: 0), GridItem(.flexible(minimum: 50), spacing: 0)]
    
    let farger: [Color] = [Color.teal, Color.red, Color.green, Color.indigo, Color.brown, Color.mint, Color.orange, Color.pink, Color.purple, Color.yellow, Color.gray, Color.cyan]
    
    var body: some View {
        HStack {
            Text(elev.navn).font(.largeTitle).frame(alignment: .center)
                /*.fileExporter(isPresented: $visFileexporter, document: data!, contentType: .PDF) { resultat in
                    switch resultat {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }*/
            
            Button {
                let docuementDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let outputfileURL: URL? = docuementDirectory.appendingPathComponent("\(prøve.navn + " " + elev.navn).pdf")
                exportPDF(outputfileURL: outputfileURL){
                    elevTilbakemeldingVisning(elev: elev, visElevTilbakemleding:$visElevTilbakemleding , prøve: prøve)
                } completion: { status, url in
                    if let url = url,status{
                        print("exportPDF: ")
                        print(url)
                        let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScene = scenes.first as? UIWindowScene
                        let window = windowScene?.windows.last
                        window?.rootViewController?.present(controller, animated: true)
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
            
            VStack(alignment: .listRowSeparatorLeading){
                LazyVGrid(columns: poengKolonner, alignment: .leading, spacing: 15) {
                    ForEach(prøve.oppgaver) { oppgave in
                        if let elevIndeks = prøve.poengRad(elevId: elev.id){
                            if let oppgaveIndeks = prøve.oppgaveIndexMedKjentElev(oppgaveId: oppgave.id, elevIndex: elevIndeks) {
                                VStack(spacing: 0) {
                                    Text(oppgave.navn).frame(width: 50, height: 20, alignment: .center).background(.green).border(.primary).fontWeight(.bold)
                                    Text(String(oppgave.maksPoeng ?? -1)).frame(width: 50, height: 20, alignment: .center).border(.primary).background(.orange)
                                    Text(prøve.poeng[elevIndeks][oppgaveIndeks].poeng).frame(width: 50, height: 20, alignment: .center).border(.primary)
                                }
                            }
                            
                        }
                    }
                }
                LazyVGrid(columns: kategoriKolonner, spacing: 30) {
                    ForEach(prøve.kategorier) { kategori in
                        if let kategoriIndex = prøve.kategoriIndex(kategoriId: kategori.id) {
                            if(maxPoengKategori(kategoriIndex: kategoriIndex) > 0) {
                                VStack {
                                    Text(prøve.kategorier[kategoriIndex].navn)
                                    kakediagram(desimaltall: Double(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex)), farge:farger[kategoriIndex % farger.count]).frame(width: 150, height: 150, alignment: .center)
                                    Text(String(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)) + "/" + String(maxPoengKategori(kategoriIndex: kategoriIndex)))
                                }
                            }
                        }
                    }
                }
                Text(.init(lagElevtilbakemelding())).frame(alignment: .leading)
                TextField("Framovermelding", text: $prøve.elever[prøve.elever.firstIndex{$0.id == elev.id}!].framovermelding, axis: .vertical)
                
                
                if(prøve.visEleverKarakter){
                    HStack {
                        Text("Karakter").fontWeight(.bold)
                        if(elev.låstKarakter) {
                            Text(prøve.finnKarakter(elevIndeks: prøve.elever.firstIndex{$0.id == elev.id}!))
                        }
                        else {
                            Text(elev.karakter)
                        }
                    }
                }
                
            }.padding(20).frame(width: 500)
        }
        Button("Lukk") {
            visElevTilbakemleding = nil
        }

        
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
    
    func elevPoengKategori(elevIndex: Int, kategoriIndex: Int) -> Float {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        var sum: Float = 0
        for oppgave in prøve.oppgaver {
            if let oppgaveIndex = prøve.oppgaveIndexMedKjentElev(oppgaveId: oppgave.id, elevIndex: elevIndex) {
                if(prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex].verdi){
                    let tall = formatter.number(from: prøve.poeng[elevIndex][oppgaveIndex].poeng) as? Float
                    if(tall != nil) {
                        sum += tall!
                    }
                }
            }
        }
        return sum
    }
    
    func lagElevtilbakemelding() -> String {
        var høy: String = "**" + prøve.tilbakemeldinger[0].tekst + ":** "
        var middels: String = "**" + prøve.tilbakemeldinger[1].tekst + ":** "
        var lav: String = "**" + prøve.tilbakemeldinger[2].tekst + ":** "
        var taMedHøy: Bool = false
        var taMedMiddels: Bool = false
        var taMedLav: Bool = false
        for kategori in prøve.kategorier {
            if let kategoriIndex = prøve.kategoriIndex(kategoriId: kategori.id){
                if(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex) > (prøve.tilbakemeldinger[0].nedreGrense ?? 66) / 100) {
                    høy += prøve.kategorier[kategoriIndex].navn + ", "
                    taMedHøy = true
                }
                
                else if(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex) > (prøve.tilbakemeldinger[1].nedreGrense ?? 33) / 100) {
                    middels += prøve.kategorier[kategoriIndex].navn + ", "
                    taMedMiddels = true
                }
                
                else if(elevPoengKategori(elevIndex: prøve.elever.firstIndex{$0.id == elev.id}!, kategoriIndex: kategoriIndex)/maxPoengKategori(kategoriIndex: kategoriIndex) >= (prøve.tilbakemeldinger[2].nedreGrense ?? 0)/100) {
                    lav += prøve.kategorier[kategoriIndex].navn + ", "
                    taMedLav = true
                }
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
