//
//  QRCodeScanner.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import SwiftUI
import CodeScanner
import WalletConnectSign

struct QRCodeScannerView: View {

    @EnvironmentObject var walletConnectSerivice: WalletConnectService

    @StateObject var viewModel = QRCodeScannerViewModel()
    @State var scanMode: ScanMode = .oncePerCode

    var body: some View {
        ZStack {
            switch viewModel.cameraAuthorizationStatus {
            case .authorized:
                CodeScannerView(codeTypes: [.qr], scanMode: scanMode) { result in
                    if case let .success(scannedData) = result,
                       let uri = WalletConnectURI(string: scannedData.string) {
                        walletConnectSerivice.connect(uri)
                    }
                }
            case .notDetermined:
                Button(action: {
                    viewModel.requestCameraAccess()
                }, label: {
                    Text("Click to allow camera access")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                })
            default:
                Text("Camera access was declined")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(12)
            }
        }
    }
}
