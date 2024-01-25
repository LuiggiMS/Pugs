//
//  FeedApiManager.swift
//  Pugs
//

import Foundation
import Alamofire

class FeedAPIManager {
  
    func getFeedData(completion: @escaping (Result<PugResponse, Error>) -> Void) {
        guard let apiUrl = URL(string: "\(Constant.baseURL)/api/breed/pug/images/random/20") else {
            let invalidURLError = NSError(domain: "Invalid URL", code: -1, userInfo: nil)
            completion(.failure(invalidURLError))
            return
        }
        
        AF.request(apiUrl).validate().responseDecodable(of: PugResponse.self) { response in
            switch response.result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
