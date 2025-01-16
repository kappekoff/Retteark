//
//  skrivInnOppgaver.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 23/11/2022.
//

import Foundation
import RegexBuilder

func lagOppgaver(input: String) -> [String] {
    
    let storBokstav = Regex {
        ChoiceOf {
            "A"
            "B"
            "C"
            "D"
            "E"
            "F"
            "G"
            "H"
            "I"
            "J"
            "K"
            "L"
            "M"
            "N"
            "O"
            "P"
            "Q"
            "R"
            "S"
            "T"
            "U"
            "V"
            "W"
            "X"
            "Y"
            "Z"
            "Æ"
            "Ø"
            "Å"
        }
    }
    
    let litenBokstav = Regex {
        ChoiceOf{
            "a"
            "b"
            "c"
            "d"
            "e"
            "f"
            "g"
            "h"
            "i"
            "j"
            "k"
            "l"
            "m"
            "n"
            "o"
            "p"
            "q"
            "r"
            "s"
            "t"
            "u"
            "v"
            "w"
            "x"
            "y"
            "z"
            "æ"
            "ø"
            "å"
        }
    }
    
    let tall = Regex {
        ChoiceOf{
            "1"
            "2"
            "3"
            "4"
            "5"
            "6"
            "7"
            "8"
            "9"
            "0"
        }
    }
    
    let nedre  = Reference(Substring.self)
    let øvre = Reference(Substring.self)
    let oppgave = Reference(Substring.self)
    let navn = Regex {
        Capture(as: oppgave){
            OneOrMore {
                ChoiceOf {
                    litenBokstav
                    storBokstav
                    tall
                    " "
                }
            }
        }
        "."
    }
    let grenser = Regex {
        Capture(as: nedre) {
            ChoiceOf {
                OneOrMore {
                    tall
                }
                OneOrMore {
                    litenBokstav
                }
                OneOrMore {
                    storBokstav
                }
            }
        }
        "-"
        Capture(as: øvre) {
            ChoiceOf {
                OneOrMore {
                    tall
                }
                OneOrMore {
                    litenBokstav
                }
                OneOrMore {
                    storBokstav
                }
            }
        }
    }
    let resultat_navn = input.matches(of: navn)
    let resultat_grenser = input.matches(of: grenser)
    
    var grensene: [String] = []
    var oppgavenavn: [String] = []
    for str in resultat_grenser {
        grensene.append(String(str[nedre]))
    }
    for str in resultat_grenser {
        grensene.append(String(str[øvre]))
    }
    
    for str in resultat_navn {
        oppgavenavn.append(String(str[oppgave]))
    }
    if(grensene[optional: 0]?.isLowercae == true){
        grensene[1] = (grensene[optional: 1] ?? grensene[0]).lowercased()
    }
    else if(grensene[optional: 0]?.isUppercase == true){
        grensene[1] = (grensene[optional: 1] ?? grensene[0]).uppercased()
    }
    var oppgaver:[String] = []
    if let nedreGrense = Int(grensene[optional: 0] ?? ""), let øvreGrense = Int(grensene[optional: 1] ?? ""){
        for tallVerdi in nedreGrense...øvreGrense {
            oppgaver.append((oppgavenavn[optional: 0] ?? "") + String(tallVerdi))
        }
        
    }
    else if let nedreGrense = grensene[optional: 0], let øvreGrense = grensene[optional: 1] {
        for skalarverdi in UnicodeScalar(nedreGrense)!.value...UnicodeScalar(øvreGrense)!.value {
            oppgaver.append((oppgavenavn[optional: 0] ?? "") + String(UnicodeScalar(skalarverdi)!))
            
        }
    }
    else {
        if(!input.isEmpty){
            oppgaver.append(input)
        }
    }
    
    return oppgaver
}

func oppgaverFraListeMedOppgavenavn(listeMedOppgavenavn: [String], maksPoeng: Float?) -> [Oppgave] {
    var oppgaver:[Oppgave] = []
    for oppgavenavn in listeMedOppgavenavn {
        oppgaver.append(Oppgave(navn: oppgavenavn, maksPoeng: maksPoeng ?? 2))
    }
    return oppgaver
}
