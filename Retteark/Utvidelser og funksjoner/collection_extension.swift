//
//  collection_extension.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 24/11/2022.
//

import Foundation
extension Collection {

    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }

}

extension String {
    var isLowercae: Bool {
        return self == self.lowercased()
    }
    
    var isUppercase: Bool {
        return self == self.uppercased()
    }
}
