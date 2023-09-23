//
//  Request+Extension.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation
import WalletConnectSign

extension Request {

    /// Only for internal purposes of decoding WalletConnect request's parameters.
    private struct RequestParams<T: Decodable>: Decodable {
        let params: [T]
    }

    func decodeParams<T: Decodable>() throws -> [T]? {
        guard let jsonData = try? params.get(Data.self) else { return nil }
        let requestParams: RequestParams<T>? = try JSONDecoder().decode(RequestParams<T>.self, from: jsonData)
        return requestParams?.params
    }
}
