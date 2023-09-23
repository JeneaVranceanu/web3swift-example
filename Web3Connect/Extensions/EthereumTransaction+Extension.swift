//
//  EthereumTransaction+Extension.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation
import Web3Core
import web3swift
import BigInt

extension CodableTransaction {

    static func from(_ ethTransaction: EthSendTransaction) -> CodableTransaction {
        let data = Data.fromHex(ethTransaction.data ?? "")
        let to = EthereumAddress(ethTransaction.to ?? "")
        let isContractDeployment = data != nil && !data!.isEmpty && to == nil
        // Though, should always be 10 for nonce.
        let nonceRadix = (ethTransaction.nonce ?? "0").hasHexPrefix() ? 16 : 10
        return CodableTransaction(type: TransactionType.legacy,
                                  to: isContractDeployment ? .contractDeploymentAddress() : to!,
                                  nonce: BigUInt(ethTransaction.nonce?.stripHexPrefix() ?? "0", radix: nonceRadix) ?? 0,
                                  // IMPORTANT: Chain ID must be used from your provider
                                  chainID: 1,
                                  value: BigUInt(ethTransaction.value?.stripHexPrefix()
                                                 ?? "0", radix: 16) ?? 0,
                                  data: data ?? Data(),
                                  gasLimit: BigUInt(ethTransaction.gas?.stripHexPrefix() ?? "0", radix: 16) ?? 0,
                                  gasPrice: BigUInt(ethTransaction.gasPrice?.stripHexPrefix() ?? "0", radix: 16),
                                  v: 0,
                                  r: 0,
                                  s: 0)
    }
}
