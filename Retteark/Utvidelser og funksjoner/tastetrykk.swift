//
//  tastetrykk.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 11/11/2022.
//
import Foundation
import CoreGraphics

extension CGKeyCode
{
    // Define whatever key codes you want to detect here
    static let kVK_LeftArrow                 : CGKeyCode = 0x7B
    static let kVK_RightArrow                : CGKeyCode = 0x7C
    static let kVK_DownArrow                 : CGKeyCode = 0x7D
    static let kVK_UpArrow                   : CGKeyCode = 0x7E

    var isPressed: Bool {
        CGEventSource.keyState(.combinedSessionState, key: self)
    }
}
