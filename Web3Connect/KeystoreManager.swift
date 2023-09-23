//
//  KeystoreManager.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//


import Foundation
import Web3Core
import KeychainAccess

final class KeystoreManager: ObservableObject {

    static let shared = KeystoreManager()

    private static let mnemonicsKey = "mnemonics"
    private static let keychain = Keychain(service: "web3connect.sample.app")

    @Published private(set) var keystore: BIP32Keystore?

    private init() {
        DispatchQueue.global().async {
            var keystore: BIP32Keystore?
            if (try! self.hasKeystoreSaved()) ?? false {
                keystore = try! self.loadKeystore()
            }

            if keystore == nil {
                keystore = try! self.generateKeystore()
            }

            if let keystore = keystore, (keystore.addresses ?? []).isEmpty {
                try! keystore.createNewChildAccount(password: "")
            }

            DispatchQueue.main.async {
                self.keystore = keystore
            }
        }
    }

    private func hasKeystoreSaved() throws -> Bool {
        return try KeystoreManager.keychain.getString(KeystoreManager.mnemonicsKey) != nil
    }

    private func loadKeystore() throws -> BIP32Keystore? {
        let mnemonics = try KeystoreManager.keychain.getString(KeystoreManager.mnemonicsKey)!
        let bip32Keystore = try BIP32Keystore(mnemonics: mnemonics, password: "")
        return bip32Keystore
    }

    private func generateKeystore() throws -> BIP32Keystore {
        let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 128)!
        let bip32Keystore = try BIP32Keystore(mnemonics: mnemonics, password: "")
        try KeystoreManager.keychain.set(mnemonics, key: KeystoreManager.mnemonicsKey)
        return bip32Keystore!
    }

}
