//
//  bakgrunsfarger.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 04/12/2022.
//

import Foundation
import SwiftUI

public extension Color {

    #if os(macOS)
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
    static let placeholderText = Color(NSColor.placeholderTextColor)
    #else
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let placeholderText = Color(UIColor.placeholderText)
    #endif
}
