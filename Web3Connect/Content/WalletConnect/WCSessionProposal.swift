//
//  WCSessionProposal.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import SwiftUI
import web3swift
import Web3Core
import Foundation
import WalletConnectSign

struct WCSessionProposalView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var keystoreManager: KeystoreManager

    @ObservedObject var viewModel: WCSessionProposalViewModel

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("WCSessionProposalView")
                    .padding([.top, .leading, .trailing], 24)

                Text((try? viewModel.proposal.asJsonString()) ?? viewModel.proposal.pairingTopic)
                    .padding(24)

                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.reject()
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Reject")
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding([.top, .bottom], 2)
                            .padding([.leading, .trailing], 4)
                            .multilineTextAlignment(.center)
                    })
                    .background(.red)
                    .foregroundColor(.white)

                    Button(action: {
                        Task {
                            await viewModel.approve(keystoreManager.keystore!.addresses ?? [])
                            presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("Confirm")
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding([.top, .bottom], 2)
                            .padding([.leading, .trailing], 4)
                            .multilineTextAlignment(.center)
                    })
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 28)
            }
            .frame(minHeight: proxy.size.height, maxHeight: .infinity)
            .edgesIgnoringSafeArea([.top, .bottom])
        }
    }

}
