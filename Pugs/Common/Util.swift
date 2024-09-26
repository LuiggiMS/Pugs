//
//  Util.swift
//  Pugs
//

import Foundation
import Reachability

class Util {
    
    static let shared = Util() // Instancia única del singleton
    private let reachability = try! Reachability()
    
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {

        reachability.whenReachable = { [weak self] reachability in
            guard let self = self else { return }
            reachability.stopNotifier()
            completion(true)
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            guard let self = self else { return }
            reachability.stopNotifier()
            completion(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
            completion(false)
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }

}

