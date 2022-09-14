//
//  Klasse.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import Foundation

class Prøve: ObservableObject, Hashable, Identifiable, Codable{
    static func == (lhs: Prøve, rhs: Prøve) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    @Published var navn: String
    var id: String = UUID().uuidString
    @Published var elever: [Elev] = []
    @Published var oppgaver: [Oppgave] = []
    @Published var poeng: [[Poeng]] = []
    @Published var kategorier: [Kategori] = []
    @Published var kategorierOgOppgaver: [[Bool]] = []
    @Published var tilbakemeldinger: [Tilbakemelding] = [Tilbakemelding(tekst: "Du viser høy kompetanse", nedreGrense: 66), Tilbakemelding(tekst: "Du viser middels kompetanse", nedreGrense: 33), Tilbakemelding(tekst: "Du viser noe kompetanse", nedreGrense: 0)]
    

    
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
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        navn = try container.decode(String.self, forKey: .navn)
        id = try container.decode(String.self, forKey: .id)
        elever = try container.decode([Elev].self, forKey: .elever)
        oppgaver = try container.decode([Oppgave].self, forKey: .oppgaver)
        poeng = try container.decode([[Poeng]].self, forKey: .poeng)
        kategorier = try container.decode([Kategori].self, forKey: .kategorier)
        kategorierOgOppgaver = try container.decode([[Bool]].self, forKey: .kategorierOgOppgaver)
        tilbakemeldinger = try container.decode([Tilbakemelding].self, forKey: .tilbakemeldinger)
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
    }
    init(navn: String, elever: [Elev], oppgaver: [Oppgave], kategorier: [Kategori]) {
        
        self.elever = elever
        self.oppgaver = oppgaver
        self.kategorier = kategorier
        self.navn = navn
    
        for i in 0..<elever.count {
            self.poeng.append([])
            for j  in 0..<oppgaver.count {
                self.poeng[i].append(Poeng(id: [i, j], poeng: round(Float.random(in: 0...(oppgaver[j].maksPoeng ?? 0)))))
            }
        }
        
        for i in 0..<self.kategorier.count{
            self.kategorierOgOppgaver .append([])
            for _ in 0..<self.oppgaver.count {
                kategorierOgOppgaver[i].append(false)
            }
        }
    }
    
    func endrePoengAlleElever(oppgaveIndeks: Int, endringsfaktor: Float){
        self.objectWillChange.send()
        for i in 0..<self.elever.count {
            self.poeng[i][oppgaveIndeks].poeng = (self.poeng[i][oppgaveIndeks].poeng ?? 0) * endringsfaktor
            print(self.poeng[i][oppgaveIndeks].poeng ?? -1)
        }
        
    }
    
    func printPoeng() {
        print(self.poeng)
    }
}


var oppgaver_test = [
    Oppgave(id: 1, navn: "1a", maksPoeng: 0.5),
    Oppgave(id: 2, navn: "1b", maksPoeng: 1),
    Oppgave(id: 3, navn: "1c", maksPoeng: 3),
    Oppgave(id: 4, navn: "2", maksPoeng: 2),
    Oppgave(id: 5, navn: "3", maksPoeng: 5.5),
    Oppgave(id: 6, navn: "4a", maksPoeng: 3.5),
    Oppgave(id: 7, navn: "4b", maksPoeng: 2.5),
    Oppgave(id: 8, navn: "5", maksPoeng: 1.5),
    Oppgave(id: 9, navn: "6", maksPoeng: 10)
    ]
    

var kategoier_test = [
    Kategori(navn: "Algebra", id: 1),
    Kategori(navn: "Geometri", id: 2),
    Kategori(navn: "Del 1", id: 3),
    Kategori(navn: "Del 2", id: 4)
    ]
