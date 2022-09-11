//
//  prøveOversiktVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 10/09/2022.
//

import SwiftUI

struct prøveOversiktVisning: View {
    var klasse: Klasse
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(klasse.prøver){prøve in
                    NavigationLink(value: prøve){
                        HStack {
                            Text(prøve.navn)
                            
                        }
                    }
                    NavigationLink(value: prøve){
                        poengTabellView(prøve: prøve)
                    }
                }
            }
        }
    }
}



