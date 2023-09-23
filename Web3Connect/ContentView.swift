//
//  ContentView.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var walletConnectService: WalletConnectService
    @EnvironmentObject var walletConnectRequestListener: WalletConnectRequestListener
    @EnvironmentObject var walletConnectSessionProposalListener: WalletConnectSessionProposalListener

    @State private var isShowingQRCodeScanner = false
    @State private var isShowingSessionProposalScreen = false
    @State private var isShowingEthSendTransactionScreen = false

    @State private var sessionProposalViewModel: WCSessionProposalViewModel?

    @State private var transactionRequestViewModel: TransactionRequestViewModel?

    var body: some View {
        VStack {
            NavigationStack {
                NavigationLink("QR code scanner", isActive: $isShowingQRCodeScanner) {
                    QRCodeScannerView()
                }
            }
        }
        .onChange(of: walletConnectRequestListener.requestToProcess, perform: { requestToProcess in
            if let requestToProcess = requestToProcess {
                switch requestToProcess.method {
                case "eth_sendTransaction":
                    transactionRequestViewModel = TransactionRequestViewModel(requestToProcess)
                    isShowingEthSendTransactionScreen = true
                    break
                default:
                    NSLog("Only eth_sendTransaction is supported")
                    break
                }
            }
        })
        .onChange(of: walletConnectSessionProposalListener.proposal,
                  perform: { sessionProposal in
            if let sessionProposal = sessionProposal {
                sessionProposalViewModel = WCSessionProposalViewModel(sessionProposal, walletConnectService)
                isShowingSessionProposalScreen = true
            }
        })
        .fullScreenCover(isPresented: $isShowingSessionProposalScreen) {
            if let sessionProposalViewModel = sessionProposalViewModel {
                WCSessionProposalView(viewModel: sessionProposalViewModel)
            }
        }
        .fullScreenCover(isPresented: $isShowingEthSendTransactionScreen) {
            if let transactionRequestViewModel = transactionRequestViewModel {
                TransactionExecutionRequestView(viewModel: transactionRequestViewModel)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WalletConnectService.default)
    }
}
