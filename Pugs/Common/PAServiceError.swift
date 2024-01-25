//
//  PAServiceError.swift
//  Pugs
//

import Alamofire
import Foundation

enum PAServiceError: Error, Equatable {
    case noInternetConnection
    case requestFailed(Int)
    case other(Error)
    
    static func == (lhs: PAServiceError, rhs: PAServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternetConnection, .noInternetConnection):
            return true
        case let (.requestFailed(lhsCode), .requestFailed(rhsCode)):
            return lhsCode == rhsCode
        case let (.other(lhsError), .other(rhsError)):
            return "\(lhsError)" == "\(rhsError)"
        default:
            return false
        }
    }

    static func mapError(_ error: Error) -> PAServiceError {
        if let networkError = error as? AFError {
            switch networkError {
            case let .sessionTaskFailed(error):
                if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                    return .noInternetConnection
                } else {
                    return .other(error)
                }
            default:
                return .other(error)
            }
        }
        return .other(error)
    }
}
