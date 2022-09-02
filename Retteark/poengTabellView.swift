//
//  poengTabellView.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/08/2022.
//

import SwiftUI

struct poengTabellView: View {
    
    @ObservedObject var prøve: Prøve
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0){
            GridRow{
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                ForEach($prøve.oppgaver){oppgave in
                    TextField("Oppgave navn", text: oppgave.navn)
                }
                Image(systemName: "sum")
                Image(systemName: "graduationcap.fill")
                Image(systemName: "lock.fill")
            }
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .font(.title)
            .fontWeight(.bold)
            .border(.primary)
            .background(.green)
            .multilineTextAlignment(.center)
            GridRow{
                Image(systemName: "light.max")
                ForEach(0..<prøve.oppgaver.count){indeks in
                    PoengView(poeng: $prøve.oppgaver[indeks].maksPoeng)
                        /*.onSubmit({ //Kode for å endre poeng for alle elever. Fungerer ikke nå
                        
                            let endringsfaktor = (prøve.oppgaver[indeks].maksPoeng ?? 0) / prøve.oppgaver[indeks].maksPoengGammelVerdi
                            
                            prøve.oppgaver[indeks].maksPoengGammelVerdi = prøve.oppgaver[indeks].maksPoeng ?? 0

                            prøve.endrePoengAlleElever(oppgaveIndeks: indeks, endringsfaktor: endringsfaktor)
                            
                        })*/
                }
                Text(String(prøve.oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +)))
                Text("6")
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            }
            .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
            .font(.title)
            .border(.primary)
            .fontWeight(.bold)
            .background(.gray)
            ForEach(0..<prøve.elever.count){elevIndeks in
                GridRow(){
                    /*Button(Text(prøve.elever[elevIndeks].navn), action: {
                        elevVurdering(elevNavn: prøve.elever[elevIndeks].navn, elevIndex: elevIndeks)
                    })*/
                    Text(prøve.elever[elevIndeks].navn)
                        
                    ForEach(0..<prøve.oppgaver.count){ poengIndeks in
                        PoengView(poeng: $prøve.poeng[elevIndeks][poengIndeks].poeng)
                            .background(elevIndeks % 2 != 0 ? .white:.orange)
                    }
                    sumCelle(poeng: $prøve.poeng[elevIndeks], farge: elevIndeks % 2 != 0)
                    karakterView(poeng: $prøve.poeng[elevIndeks], farge: elevIndeks % 2 != 0, maxPoeng: prøve.oppgaver.map({$0.maksPoeng ?? 0}).reduce(0, +), elev: $prøve.elever[elevIndeks])
                        .background(elevIndeks % 2 != 0 ? .white:.orange)
                    Button(action: {
                        prøve.elever[elevIndeks].låstKarakter.toggle()
                    }, label: {
                        Image(systemName: prøve.elever[elevIndeks].låstKarakter ? "lock.open.fill" : "lock.fill")
                    })
                }
                .font(.title3)
                .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: 50)
                .border(.primary)
                .background(elevIndeks % 2 != 0 ? .white:.orange)
            }
        }
    }
}
