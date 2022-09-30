//
//  Klasseoversikt.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import Foundation

class Klasseoversikt: ObservableObject {
    
    @Published var klasser: [Klasse]
    var lagret_tidspunkt: Date?
    
    init(){
        
        self.klasser = [Klasse(navn: "2IMT", elever: elever_test, skoleÅr: "22/23")]
        if(FileManager().documentDoesExist(named: filnavn)){
            lastInnKlasser()
        }
        lagret_tidspunkt = nil
        
        
    }
    
    func lastInnKlasser() {
        FileManager().readDocument(docName: filnavn) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    klasser = try decoder.decode([Klasse].self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func lagreKlasser() {
        let enkoder = JSONEncoder()
        do {
            let data = try enkoder.encode(klasser)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, documentname: filnavn) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func finnKlasseFraId(id: String) -> Klasse? {
        return self.klasser.first(where: {$0.id == id})
    }
    
}

var elever_test = [
    Elev(id: 1, navn: "Petter"),
    Elev(id: 2, navn: "Åse"),
    Elev(id: 3, navn: "Stein"),
    Elev(id: 4, navn: "Per"),
    Elev(id: 5, navn: "Lise"),
    Elev(id: 6, navn: "Jinbo"),
    Elev(id: 7, navn: "Ronja"),
    Elev(id: 8, navn: "Ask"),
    Elev(id: 9, navn: "Fredrik"),
    Elev(id: 10, navn: "Adam")
    ]
