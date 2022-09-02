//
//  elevKategoriVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 02/09/2022.
//

import SwiftUI

struct elevKategoriVisning: View {
    var elevNavn: String
    @Binding var visElevKategori:Bool
    
    var body: some View {
        HStack{
            VStack {
                Button("Tilbake") {
                    visElevKategori = false
                }
                Spacer()
                
            }
        Text(elevNavn)
        }
            
        }
        
    }
