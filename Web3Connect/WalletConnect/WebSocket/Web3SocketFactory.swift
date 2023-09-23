//
//  Web3SocketFactory.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//


import Foundation
import WalletConnectRelay

struct Web3SocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        let client = WebSocketClient(url)
        client.resume()
        return client
    }
}

