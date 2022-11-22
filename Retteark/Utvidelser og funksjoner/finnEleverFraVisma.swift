//
//  finnEleverFraVisma.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 22/09/2022.
//

import Foundation
import RegexBuilder

func vismaTilElever(visma: String) -> [String] {
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
    
    let navn = Regex {
        storBokstav
        OneOrMore(litenBokstav)
        Optionally{
            ChoiceOf {
                "-"
                "–"
                "—"
            }
            storBokstav
            OneOrMore {
                litenBokstav
            }
        }
        " "
        storBokstav
    }
    let fornavn = Reference(Substring.self)
    
    let regex = Regex {
        Capture(as: fornavn) {
            navn
        }
    }

    let resultat = visma.matches(of: regex)
    var elever: [String] = []
    for elev in resultat {
        elever.append(String(elev[fornavn]))
    }
    return elever
}

