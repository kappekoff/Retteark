//
//  filemanager_extension.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 13/09/2022.
//

import Foundation

let filnavn = "Retteark.json"

extension FileManager {
    static var docDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveDocument(contents: String, docname: String, completion: (Error?) -> Void) {
        let url = Self.docDirURL.appendingPathComponent(docname)
        do{
            try contents.write(to: url, atomically: true, encoding: .utf8)
        }
        catch {
            completion(error)
        }
    }
    
    
    func readDocument(docname: String, completion: (Result<Data, Error>) -> Void) {
        let url = Self.docDirURL.appendingPathComponent(docname)
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func documentDoesExist(named docname: String) -> Bool {
        fileExists(atPath: Self.docDirURL.appendingPathComponent(docname).path)
    }
    
}

