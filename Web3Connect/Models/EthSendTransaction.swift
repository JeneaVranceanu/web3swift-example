//
//  EthSendTransaction.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation

struct EthSendTransaction: Decodable {
    let from: String
    private(set) var to: String?
    private(set) var gas: String?
    private(set) var gasPrice: String?
    private(set) var value: String?
    private(set) var data: String?
    private(set) var nonce: String?
}
