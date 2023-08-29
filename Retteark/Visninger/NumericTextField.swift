//
//  NumericTextField.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 03/08/2022.
//

import SwiftUI

public extension String {
    func numericValue(allowDecimalSeparator: Bool) -> String {
        var hasFoundDecimal = false
        return self.filter {
            if $0.isWholeNumber {
                return true
            } else if allowDecimalSeparator && String($0) == (Locale.current.decimalSeparator ?? ".") {
                defer { hasFoundDecimal = true }
                return !hasFoundDecimal
            }
            return false
        }
    }
}

public struct NumericTextField: View {

    @Binding private var number: Float?
    @State private var string: String
    private let isDecimalAllowed: Bool
    private let formatter: NumberFormatter = NumberFormatter()

    private let title: String
    private let onEditingChanged: (Bool) -> Void
    private let onCommit: () -> Void

    public init(_ titleKey: String, number: Binding<Float?>, isDecimalAllowed: Bool, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
        formatter.numberStyle = .decimal
        _number = number
        if let number = number.wrappedValue, let string = formatter.string(from: number as NSNumber) {
            _string = State(initialValue: string)
        } else {
            _string = State(initialValue: "")
        }
        self.isDecimalAllowed = isDecimalAllowed
        title = titleKey
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }

    public var body: some View {
        return TextField(title, text: $string, onEditingChanged: onEditingChanged, onCommit: onCommit)
            .onChange(of: string) {
                numberChanged(newValue: string)
            }
        
    }
    private func numberChanged(newValue: String) {
        let numeric = newValue.numericValue(allowDecimalSeparator: isDecimalAllowed)
        if newValue != numeric {
            string = numeric
        }
        number = formatter.number(from: string) as? Float
        
    }
}
