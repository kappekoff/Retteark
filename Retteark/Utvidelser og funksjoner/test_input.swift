//
//  test_input.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 27/10/2022.
//

import Foundation

class Testdata {

  let karaktergrenser_test = [
      Karaktergrense(karakter: "6", grense: 99),
      Karaktergrense(karakter: "6-", grense: 93),
      Karaktergrense(karakter: "6/5", grense: 90),
      Karaktergrense(karakter: "5++", grense: 87),
      Karaktergrense(karakter: "5+", grense: 83),
      Karaktergrense(karakter: "5", grense: 80),
      Karaktergrense(karakter: "5-", grense: 77),
      Karaktergrense(karakter: "5/4", grense: 74),
      Karaktergrense(karakter: "4++", grense: 70),
      Karaktergrense(karakter: "4+", grense: 67),
      Karaktergrense(karakter: "4", grense: 64),
      Karaktergrense(karakter: "4-", grense: 61),
      Karaktergrense(karakter: "4/3", grense: 58),
      Karaktergrense(karakter: "3++", grense: 54),
      Karaktergrense(karakter: "3+", grense: 51),
      Karaktergrense(karakter: "3", grense: 48),
      Karaktergrense(karakter: "3-", grense: 45),
      Karaktergrense(karakter: "3/2", grense: 41),
      Karaktergrense(karakter: "2++", grense: 38),
      Karaktergrense(karakter: "2+", grense: 35),
      Karaktergrense(karakter: "2", grense: 32),
      Karaktergrense(karakter: "2-", grense: 29),
      Karaktergrense(karakter: "2/1", grense: 25),
      Karaktergrense(karakter: "1++", grense: 22),
      Karaktergrense(karakter: "1+", grense: 19),
      Karaktergrense(karakter: "1", grense: 0)
  ]
    let tilbakemeldinger: [Tilbakemelding] = [Tilbakemelding(tekst: "Du viser høy kompetanse", nedreGrense: 66), Tilbakemelding(tekst: "Du viser middels kompetanse", nedreGrense: 33), Tilbakemelding(tekst: "Arbeid mer med", nedreGrense: 0)]
}


   
