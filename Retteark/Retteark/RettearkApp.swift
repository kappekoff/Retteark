//
//  RettearkApp.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI


@main
struct RettearkApp: App {
    @StateObject var ko: Klasseoversikt = Klasseoversikt()
    var body: some Scene {
        WindowGroup {
            klasseVisning(klasseoversikt: Klasseoversikt())
        }
    }
}
