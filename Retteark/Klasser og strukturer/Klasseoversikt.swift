//
//  Klasseoversikt.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import Foundation

class Klasseoversikt: ObservableObject, Equatable {
    
    @Published var klasser: [Klasse]
    let id: String = UUID().uuidString
    var lagret_tidspunkt: Date?
    
    init(){
        
        self.klasser = [Klasse(navn: "1IMT", elever: elever_test_1, skoleÅr: "22/23"),
                        Klasse(navn: "2IMT", elever: elever_test_2, skoleÅr: "22/23"),
                        Klasse(navn: "3IMT", elever: elever_test_3, skoleÅr: "22/23")]
        if(FileManager().documentDoesExist(named: filnavn)){
            lastInnKlasser()
        }
        lagret_tidspunkt = nil
        
        
    }
    
    static func == (venstreSide: Klasseoversikt, høyreSide: Klasseoversikt) -> Bool {
        return venstreSide.id == høyreSide.id
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
    
    func klasseFraId(id: String) -> Klasse? {
        return self.klasser.first(where: {$0.id == id})
    }
    
}

