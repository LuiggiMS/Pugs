//
//  Util.swift
//  Pugs
//

import Foundation

class Localized: NSObject {
    static func key(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
