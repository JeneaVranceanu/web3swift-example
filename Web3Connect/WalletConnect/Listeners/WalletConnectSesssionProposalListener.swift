//
//  WalletConnectSesssionProposalListener.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//


import Foundation
import WalletConnectSign

final class WalletConnectSessionProposalListener: ObservableObject {

    @Published private(set) var proposal: Session.Proposal?

    func listenToChanges(of viewModel: WalletConnectService) {
        viewModel.setSessionProposalListener { [weak self] sessionProposal in
            self?.proposal = sessionProposal
        }
    }

}
