//
//  Encodable.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation

extension Encodable {
    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    func asJsonString() throws -> String? {
        String(data: try encoded(), encoding: .utf8)
    }

    func asDictionary() throws -> [String: String] {
        try JSONDecoder().decode([String: String].self, from: try encoded())
    }
}
