//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI

struct elevTilbakemeldingVisning: View {
    var elev: Elev
    @Binding var visElevTilbakemleding:VisElevTilbakemleding?
    @ObservedObject var prøve: Prøve
    
    var body: some View {
        HStack{
            VStack {
                Button("Tilbake") {
                    visElevTilbakemleding = nil
                }
                .frame(alignment: .leading)
            }
            Text(elev.navn)
        }
            
        }
        
    }
