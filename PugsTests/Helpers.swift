//
//  Helpers.swift
//  PugsTests
//


import Foundation
@testable import Pugs

func decodeDogApiResponse(from jsonString: String) throws -> PugResponse {
    guard let jsonData = jsonString.data(using: .utf8) else {
        throw NSError(domain: "Invalid JSON string", code: 0, userInfo: nil)
    }
    return try JSONDecoder().decode(PugResponse.self, from: jsonData)
}
