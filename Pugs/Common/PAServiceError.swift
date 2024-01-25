//
//  PAServiceError.swift
//  Pugs
//

import Alamofire
import Foundation

enum PAServiceError: Error {
    case noInternetConnection
    case requestFailed(Int)
    case other(Error)

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
