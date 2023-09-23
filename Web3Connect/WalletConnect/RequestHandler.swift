//
//  RequestHandler.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import web3swift
import Foundation
import WalletConnectSign

/// Simple handler with an option to specify filter for incoming requests.
/// Simply calls given closure if received request uses JSONRPC 2.0 method
/// that is in the ``SimpleRequestHandler/rpcMethods``.
/// If `rpcMethods` array is empty all requests are filtered with `true` result.
final class RequestHandler {

    private let rpcMethods: [String]
    private let receiveClosure: (Request) -> Void

    init(filterBy rpcMethods: [String] = [],
                     receiveClosure: @escaping (Request) -> Void) {
        self.rpcMethods = rpcMethods
        self.receiveClosure = receiveClosure
    }

    func filter(_ request: Request) -> Bool {
        rpcMethods.contains(request.method)
    }

    func handle(_ request: Request) {
        DispatchQueue.main.async {
            self.receiveClosure(request)
        }
    }
}
