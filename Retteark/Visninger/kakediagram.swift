//
//  kakediagram.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 31/08/2022.
//

import SwiftUI

struct kakediagram: View {
    var desimaltall: Double = 0.63
    var farge: Color = Color.teal
    
    
    
    var body: some View {
        ZStack{
            kakeStykke(startVinkel: -90, sluttVinkel: -90-desimaltall*360)
                .stroke(.black, lineWidth: 4)
                .background(kakeStykke(startVinkel: -90, sluttVinkel: -90-desimaltall*360).foregroundColor(farge))
            kakeStykke(startVinkel: -90-desimaltall*360, sluttVinkel: -90-360)
                .stroke(.black, lineWidth: 4)
                .background(kakeStykke(startVinkel: -90-desimaltall*360, sluttVinkel: -90-360).foregroundColor(Color.white))
        }
        
    }
}

struct kakeStykke: Shape {
    let startVinkel: Double
    let sluttVinkel: Double
    
    func path(in rect: CGRect) -> Path {
        Path { sti in
            sti.move(to: CGPoint(x: rect.midX, y: rect.midY))
            sti.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX, startAngle: Angle(degrees: startVinkel), endAngle: Angle(degrees:sluttVinkel), clockwise: true)
            sti.closeSubpath()
        }
    }
}
struct kakediagram_Previews: PreviewProvider {
    static var previews: some View {
        kakediagram()
    }
}
