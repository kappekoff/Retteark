//
//  Klasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import Foundation

class Prøve: Hashable, Identifiable, Codable, ObservableObject{
    static func == (lhs: Prøve, rhs: Prøve) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    @Published var navn: String
    var id: String = UUID().uuidString
    @Published var elever: [Elev] = []
    @Published var oppgaver: [Oppgave] = []
    @Published var poeng: [[Poeng]] = []
    @Published var kategorier: [Kategori] = []
    @Published var kategorierOgOppgaver: [[BoolOgId]] = []
    @Published var visEleverKarakter: Bool = true
    @Published var tilbakemeldinger: [Tilbakemelding] = [Tilbakemelding(tekst: "Du viser høy kompetanse", nedreGrense: 66), Tilbakemelding(tekst: "Du viser middels kompetanse", nedreGrense: 33), Tilbakemelding(tekst: "Arbeid mer med", nedreGrense: 0)]
    @Published var karaktergrenser: [Karaktergrense] = karaktergrenser_test
    

    
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
    
    /*func endrePoengAlleElever(oppgaveIndeks: Int, endringsfaktor: Float){
        for i in 0..<self.elever.count {
            self.poeng[i][oppgaveIndeks].poeng = (self.poeng[i][oppgaveIndeks].poeng ?? 0) * endringsfaktor
            print(self.poeng[i][oppgaveIndeks].poeng ?? -1)
        }
        
    }*/
    
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
        self.kategorier.append(Kategori(navn: "Ny kategori"))
        self.kategorierOgOppgaver.append([])
        for oppgave in self.oppgaver {
            self.kategorierOgOppgaver[self.kategorierOgOppgaver.count-1].append(BoolOgId(verdi: false, kategoriId: self.kategorier.last!.id, oppgaveId: oppgave.id))
        }
    }
    
    func sumAvPoeng(elevIndeks: Int) -> Float {

        var sum: Float = 0
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
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
        
        /*if(fått_til > 1 || fått_til < 0) {
            return "?"
        }
        else if(fått_til >= 0.9967){
            return "6"
        }
        else if(fått_til >= 0.9355){
            return "6-"
        }
        else if(fått_til >= 0.9032){
            return "6/5"
        }
        else if(fått_til >= 0.8710){
            return "5/6"
        }
        else if(fått_til >= 0.8387){
            return "5+"
        }
        else if(fått_til >= 0.8065){
            return "5"
        }
        else if(fått_til >= 0.7742){
            return "5-"
        }
        else if(fått_til >= 0.7419){
            return "5/4"
        }
        else if(fått_til >= 0.7097){
            return "4/5"
        }
        else if(fått_til >= 0.6774){
            return "4+"
        }
        else if(fått_til >= 0.6452){
            return "4"
        }
        else if(fått_til >= 0.6129){
            return "4-"
        }
        else if(fått_til >= 0.5806){
            return "4/3"
        }
        else if(fått_til >= 0.5484){
            return "3/4"
        }
        else if(fått_til >= 0.5161){
            return "3+"
        }
        else if(fått_til >= 0.4839){
            return "3"
        }
        else if(fått_til >= 0.4516){
            return "3-"
        }
        else if(fått_til >= 0.4194){
            return "3/2"
        }
        else if(fått_til >= 0.3871){
            return "2/3"
        }
        else if(fått_til >= 0.3548){
            return "2+"
        }
        else if(fått_til >= 0.3226){
            return "2"
        }
        else if(fått_til >= 0.2903){
            return "2-"
        }
        else if(fått_til >= 0.2581){
            return "2/1"
        }
        else if(fått_til >= 0.2258){
            return "1/2"
        }
        else if(fått_til >= 0.1935){
            return "1+"
        }
        else {
            return "1"
        }*/
    }
}


