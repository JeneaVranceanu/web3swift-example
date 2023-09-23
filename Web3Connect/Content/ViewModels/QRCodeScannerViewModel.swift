//
//  QRCodeScannerViewModel.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation
import AVFoundation

final class QRCodeScannerViewModel: ObservableObject {

    @Published var cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] permissionGranted in
            DispatchQueue.main.async {
                self?.cameraAuthorizationStatus = permissionGranted ? .authorized : .denied
            }
        }
    }
}

