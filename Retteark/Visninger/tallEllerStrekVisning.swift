//
//  tallEllerStrekVisning.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 05/11/2022.
//

import SwiftUI
import RegexBuilder

struct tallEllerStrekVisning: View {
    @Binding var tekst: String
    @State var tittel: String
    
    var body: some View {
        TextField(tittel, text: $tekst)
            .onChange(of: tekst, perform: endretTall(nyVerdi:))

        
    }
    func endretTall(nyVerdi: String) {
        let tallSymbol = Regex {
            ChoiceOf {
                "0"
                "1"
                "2"
                "3"
                "4"
                "5"
                "6"
                "7"
                "8"
                "9"
            }
        }
        let punkt = Regex {
            ChoiceOf {
                "."
                ","
            }
        }
        let tall = Regex {
            OneOrMore(tallSymbol)
            Optionally {
                punkt
                Optionally {
                    OneOrMore(tallSymbol)
                }
                
            }
        }
        let strek = Regex {
            ChoiceOf {
                "-"
                "–"
                "—"
            }
        }
        let tallEllerStrek = Regex {
            ChoiceOf {
                ""
                tall
                strek
            }
        }
        
        if let _ = nyVerdi.wholeMatch(of: tallEllerStrek) {
            tekst = nyVerdi.replacingOccurrences(of: ",", with: ".")
            tittel = tekst
        }
        else {
            tekst = tittel
        }
    }
}


