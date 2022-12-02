//
//  Klasseoversikt.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 09/09/2022.
//

import Foundation

class Klasseoversikt: ObservableObject, Equatable {
    
    struct Klasseinformasjon: Codable {
        var klasser: [Klasse]
        var id: String = UUID().uuidString
        var lagret_tidspunkt: Date?
    }
    
    
    @Published var klasseinformasjon: Klasseinformasjon

    init(){
       /* self.klasser = [Klasse(navn: "1IMT", elever: elever_test_1, skoleÅr: "22/23"),
                        Klasse(navn: "2IMT", elever: elever_test_2, skoleÅr: "22/23"),
                        Klasse(navn: "3IMT", elever: elever_test_3, skoleÅr: "22/23")]*/
        klasseinformasjon = Klasseinformasjon(klasser: [])
        if(FileManager().documentDoesExist(named: filnavn)){
            lastInnKlasser()
        }
    }
    
    static func == (venstreSide: Klasseoversikt, høyreSide: Klasseoversikt) -> Bool {
        return venstreSide.klasseinformasjon.id == høyreSide.klasseinformasjon.id
    }
    
    func lastInnKlasser() {
        FileManager().readDocument(docName: filnavn) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    self.klasseinformasjon = try decoder.decode(Klasseinformasjon.self, from: data)
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
        print(klasseinformasjon.lagret_tidspunkt?.formatted() ?? "Dato ikke satt")
        do {
            let data = try enkoder.encode(klasseinformasjon)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, documentname: filnavn) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            klasseinformasjon.lagret_tidspunkt = Date()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func klasseFraId(id: String) -> Klasse? {
        return self.klasseinformasjon.klasser.first(where: {$0.id == id})
    }
    
}

