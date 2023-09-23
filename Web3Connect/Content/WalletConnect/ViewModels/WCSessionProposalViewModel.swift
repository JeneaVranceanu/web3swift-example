//
//  WCSessionProposalViewModel.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import web3swift
import Web3Core
import Foundation
import WalletConnectSign


final class WCSessionProposalViewModel: ObservableObject {

    private let walletConnectService: WalletConnectService

    let proposal: Session.Proposal

    @Published private(set) var approvalError: String?

    init(_ proposal: Session.Proposal, _ walletConnectService: WalletConnectService) {
        self.proposal = proposal
        self.walletConnectService = walletConnectService
    }

    @MainActor
    func approve(_ addresses: [EthereumAddress]) async {
        do {
            try await walletConnectService.approveProposal(proposal, addresses)
        } catch {
            approvalError = error.localizedDescription
        }
    }

    func reject(_ rejectReason: RejectionReason = .userRejected) {
        Task {
            do {
                try await walletConnectService.rejectProposal(proposal, rejectReason)
            } catch {
#if DEBUG
                NSLog(error.localizedDescription)
#endif
            }
        }
    }

}
