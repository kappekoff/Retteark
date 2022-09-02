//
//  elevVurdering.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 01/09/2022.
//

import SwiftUI

struct elevVurdering: View {
    let elevNavn: String
    let elevIndex: Int
    
    var body: some View {
        VStack {
            Text(elevNavn)
            Text(String(elevIndex))
        }
        
    }
}

struct elevVurdering_Previews: PreviewProvider {
    static var previews: some View {
        elevVurdering(elevNavn: "Stein", elevIndex: 1)
    }
}
