//
//  Web3ConnectApp.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import SwiftUI
import WalletConnectSign
import Web3Core

@main
struct Web3ConnectApp: App {

    private let walletConnectRequestListener = WalletConnectRequestListener()
    private let walletConnectSessionProposalListener = WalletConnectSessionProposalListener()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(WalletConnectService.default)
                .environmentObject(walletConnectRequestListener)
                .environmentObject(walletConnectSessionProposalListener)
                .environmentObject(KeystoreManager.shared)
        }
    }

    init() {
        configureWalletConnect()
    }

    private func configureWalletConnect() {
        guard let projectId = WalletConnectService.projectId, !projectId.isEmpty else {
            NSLog("WalletConnect configuration failed. `WalletConnectService.projectId` is nil or empty.")
            return
        }

        let socketFactory = Web3SocketFactory()
        Networking.configure(projectId: projectId, socketFactory: socketFactory, socketConnectionType: .manual)
        Pair.configure(metadata: WalletConnectService.metadata)

        walletConnectRequestListener.listenToChanges(of: WalletConnectService.default)
        walletConnectSessionProposalListener.listenToChanges(of: WalletConnectService.default)
        try! Networking.instance.connect()
    }
}
