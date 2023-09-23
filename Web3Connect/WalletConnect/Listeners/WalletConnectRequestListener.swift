//
//  WalletConnectRequestListener.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//


import Foundation
import WalletConnectSign

final class WalletConnectRequestListener: ObservableObject {

    @Published private(set) var requestToProcess: Request?

    func listenToChanges(of viewModel: WalletConnectService) {
        viewModel.setRequestListener { [weak self] requestToProcess in
            self?.requestToProcess = requestToProcess
        }
    }
}

