//
//  kategoriView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI


struct kategoriView: View {
    @Binding var viserSheet: VisElevTilbakemleding?
    @ObservedObject var prøve: Prøve
    
    
    
    var body: some View {
        VStack {
            Text("Kategorier og oppgaver").font(.largeTitle)
            Grid(horizontalSpacing: 0, verticalSpacing: 0){
                GridRow{
                    Color.green.gridCellUnsizedAxes([.horizontal, .vertical]).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary)
                    ForEach(prøve.oppgaver){oppgave in
                        Text(oppgave.navn)
                    }.frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(.green)
                }
                ForEach(0..<prøve.kategorier.count){ kategoriIndex in
                    GridRow() {
                        Text(prøve.kategorier[kategoriIndex].navn).frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary).background(.orange)
                        ForEach(0..<prøve.oppgaver.count){oppgaveIndex in
                            Toggle("", isOn: $prøve.kategorierOgOppgaver[kategoriIndex][oppgaveIndex])
                        }.frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50).border(.primary)
                        
                    }
                }
            }
            Button("Tilbake") {
                viserSheet = nil
            }
        }
    }
}

/*struct kategoriView_Previews: PreviewProvider {
    static var previews: some View {
        kategoriView()
    }
}*/
