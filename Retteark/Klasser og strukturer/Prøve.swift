//
//  Klasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import Foundation
import Observation


@Observable
class Prøve: Hashable, Identifiable, Codable{
    static func == (lhs: Prøve, rhs: Prøve) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    var navn: String
    var id: String = UUID().uuidString
    var elever: [Elev] = []
    var oppgaver: [Oppgave] = []
    var poeng: [[Poeng]] = []
    var kategorier: [Kategori] = []
    var kategorierOgOppgaver: [[BoolOgId]] = []
    var visEleverKarakter: Bool = true
    var tilbakemeldinger: [Tilbakemelding] = [Tilbakemelding(tekst: "Du viser høy kompetanse", nedreGrense: 66), Tilbakemelding(tekst: "Du viser middels kompetanse", nedreGrense: 33), Tilbakemelding(tekst: "Arbeid mer med", nedreGrense: 0)]
    var karaktergrenser: [Karaktergrense] = Testdata().karaktergrenser_test
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(navn)
    }
    
   enum CodingKeys: CodingKey {
        case navn
        case id
        case elever
        case oppgaver
        case poeng
        case kategorier
        case kategorierOgOppgaver
        case tilbakemeldinger
        case visEleverKarakter
        case karaktergrenser
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        navn = try container.decode(String.self, forKey: .navn)
        id = try container.decode(String.self, forKey: .id)
        elever = try container.decode([Elev].self, forKey: .elever)
        oppgaver = try container.decode([Oppgave].self, forKey: .oppgaver)
        poeng = try container.decode([[Poeng]].self, forKey: .poeng)
        kategorier = try container.decode([Kategori].self, forKey: .kategorier)
        kategorierOgOppgaver = try container.decode([[BoolOgId]].self, forKey: .kategorierOgOppgaver)
        tilbakemeldinger = try container.decode([Tilbakemelding].self, forKey: .tilbakemeldinger)
        visEleverKarakter = try container.decode(Bool.self, forKey: .visEleverKarakter)
        karaktergrenser = try container.decode([Karaktergrense].self, forKey: .karaktergrenser)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(navn, forKey: .navn)
        try container.encode(id, forKey: .id)
        try container.encode(elever, forKey: .elever)
        try container.encode(oppgaver, forKey: .oppgaver)
        try container.encode(poeng, forKey: .poeng)
        try container.encode(kategorier, forKey: .kategorier)
        try container.encode(kategorierOgOppgaver, forKey: .kategorierOgOppgaver)
        try container.encode(tilbakemeldinger, forKey: .tilbakemeldinger)
        try container.encode(visEleverKarakter, forKey: .visEleverKarakter)
        try container.encode(karaktergrenser, forKey: .karaktergrenser)
    }
    
    init(navn: String, elever: [Elev], oppgaver: [Oppgave], kategorier: [Kategori], visEleverKarakter: Bool) {
        
        self.elever = elever
        self.oppgaver = oppgaver
        self.kategorier = kategorier
        self.navn = navn
        self.visEleverKarakter = visEleverKarakter
    
        for i in 0..<elever.count {
            self.poeng.append([])
            for j  in 0..<oppgaver.count {
                self.poeng[i].append(Poeng(id: [i, j], poeng: "", elevId: elever[i].id, OppgaveId: oppgaver[j].id))
            }
        }
        
        for i in 0..<self.kategorier.count{
            self.kategorierOgOppgaver .append([])
            for j in 0..<self.oppgaver.count {
                kategorierOgOppgaver[i].append(BoolOgId(verdi: false, kategoriId: kategorier[i].id, oppgaveId: oppgaver[j].id))
            }
        }
    }
    
    func endrePoengAlleElever(oppgaveId: String){
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        let endringsfaktor = (self.oppgaver.first(where: { $0.id == oppgaveId})?.maksPoeng ?? 0) / (self.oppgaver.first(where: { $0.id == oppgaveId})?.maksPoengGammelVerdi ?? 1)
        for elev in self.elever {
            if let elevIndeks = self.poengRad(elevId: elev.id) {
                if let oppgaveIndeks = oppgaveIndexMedKjentElev(oppgaveId: oppgaveId, elevIndex: elevIndeks){
                    if let gammelVerdi = (formatter.number(from: self.poeng[elevIndeks][oppgaveIndeks].poeng) as? Float) {
                        let  nyVerdi = gammelVerdi * endringsfaktor
                        self.poeng[elevIndeks][oppgaveIndeks].poeng = String(nyVerdi)
                    }
                }
            }
            
        }
        
        for i in 0..<self.oppgaver.count {
            if(self.oppgaver[i].id == oppgaveId){
                self.oppgaver[i].maksPoengGammelVerdi = self.oppgaver[i].maksPoeng ?? 1
            }
        }
        //self.objectWillChange.send()
        
    }
    
    func printPoeng() {
        for rad in poeng {
            for element in rad {
                print(element.poeng)
            }
            print("\n")
        }
        print("Ferdig")
    }
    
    func poengRad(elevId: String) -> Int? {
        for i in 0..<poeng.count {
            if(poeng[i][0].elevId == elevId) {
                return i
            }
        }
        return nil
    }
    
    func oppgave(elevIndeks: Int, oppgaveId: String) -> Int? {
        for i in 0..<poeng[elevIndeks].count {
            if(poeng[elevIndeks][i].oppgaveId == oppgaveId){
                return i
            }
        }
        return nil
    }
    
    func kategoriIndex(kategoriId: String) -> Int? {
        for i in 0..<kategorierOgOppgaver.count{
            if(kategorierOgOppgaver[i][0].kategoriId == kategoriId){
                return i
            }
        }
        return nil
    }
    
    func oppgaveIndexMedKjentKategori(oppgaveId: String, kateogriIndex: Int) -> Int? {
        for i in 0..<kategorierOgOppgaver[kateogriIndex].count{
            if(kategorierOgOppgaver[kateogriIndex][i].oppgaveId == oppgaveId){
                return i
            }
        }
        return nil
    }
    
    func oppgaveIndexMedKjentElev(oppgaveId: String, elevIndex: Int) -> Int? {
        for i in 0..<poeng[elevIndex].count{
            if(poeng[elevIndex][i].oppgaveId == oppgaveId){
                return i
            }
        }
        return nil
    }
    
    func leggTilKategori() {
        self.kategorier.append(Kategori(navn: ""))
        self.kategorierOgOppgaver.append([])
        for oppgave in self.oppgaver {
            self.kategorierOgOppgaver[self.kategorierOgOppgaver.count-1].append(BoolOgId(verdi: false, kategoriId: self.kategorier.last!.id, oppgaveId: oppgave.id))
        }
    }
    
    func sumAvPoeng(elevIndeks: Int) -> Float {

        var sum: Float = 0
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        for oppgave in oppgaver {
            if let oppgaveIndeks = oppgaveIndexMedKjentElev(oppgaveId: oppgave.id, elevIndex: elevIndeks){
                if let tall = formatter.number(from: poeng[elevIndeks][oppgaveIndeks].poeng) as? Float {
                    sum += tall
                }
            }
        }
        return sum
    }

    
    func finnKarakter(elevIndeks: Int) -> String {
        let maxPoeng = oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)
        let sumPoeng = sumAvPoeng(elevIndeks: elevIndeks)
        let fått_til = sumPoeng/maxPoeng
        
        if (fått_til > 1 || fått_til < 0) {
            return "?"
        }
        for karaktergrense in karaktergrenser {
            guard(karaktergrense.grense != nil) else {
                continue
            }
            if(fått_til >= karaktergrense.grense!/100) {
                return karaktergrense.karakter
            }
        }
        
        return "??"
        
    }
}


