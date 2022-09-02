//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI

struct elevKategoriVisning: View {
    var elevNavn: String
    var body: some View {
        Text(elevNavn)
    }
}

struct elevKategoriVisning_Previews: PreviewProvider {
    static var previews: some View {
        elevKategoriVisning(elevNavn: "Peder")
    }
}
