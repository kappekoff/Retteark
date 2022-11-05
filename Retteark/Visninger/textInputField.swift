//
//  textInputField.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 26/09/2022.
//

import SwiftUI

struct TextInputField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading){
            Text(title)
                .foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor )
                .offset(y: text.isEmpty ? 0: -35)
                .scaleEffect(text.isEmpty ? 1 : 0.7, anchor: .leading)
            TextField("", text: $text, axis: .vertical)
        }
        .padding(.top, 15)
        .animation(.default, value: text)
    }
}

