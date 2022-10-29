//
//  Tilbakemelding.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 14/09/2022.
//

import Foundation

struct Tilbakemelding: Codable, Hashable {
    var tekst: String
    var nedreGrense: Float?
}
