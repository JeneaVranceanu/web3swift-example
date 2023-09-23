//
//  TransactionRequestViewModel.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import BigInt
import Foundation
import WalletConnectSign
import web3swift
import Web3Core

final class TransactionRequestViewModel: ObservableObject {

    let request: Request

    @Published
    var executionResult: TransactionSendingResult?

    init(_ request: Request) {
        self.request = request
    }

    func reject() {
        Task {
            try! await WalletConnectService.default.reject(request)
        }
    }

    func execute() async {
        // Ofcourse the provider you use here should not be created on each execute call
        let provider = try! await Web3HttpProvider(url: URL(string: "https://eth.drpc.org")!, network: .Mainnet)
        let web3Instance = Web3(provider: provider)
        let ethTransactionParams: [EthSendTransaction]? = try! request.decodeParams()

        guard let params = ethTransactionParams?.first,
              let keystore = KeystoreManager.shared.keystore,
              let address = keystore.addresses?.first else {
            NSLog("Failed to create CodableTransaction")
            return
        }

        var transaction = CodableTransaction.from(params)
        try! Web3Signer.signTX(transaction: &transaction,
                          keystore: keystore,
                          account: address,
                          password: "")
        executionResult = try! await web3Instance.eth.send(raw: transaction.encode(for: .transaction)!)
    }
}

