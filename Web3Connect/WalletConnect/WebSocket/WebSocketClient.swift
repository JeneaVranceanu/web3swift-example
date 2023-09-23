//
//  WebSocketClient.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation
import WalletConnectRelay

class WebSocketClient: WebSocketClientInterface, WebSocketConnecting {

    var isConnected: Bool

    var onConnect: (() -> Void)?

    var onDisconnect: ((Error?) -> Void)?

    var onText: ((String) -> Void)?

    var request: URLRequest

    let session = URLSession(configuration: .default)
    private let webSocketTask: URLSessionWebSocketTask
    private weak var receiver: WebSocketMessageReceiver?

    private(set) var url: URL

    init(_ url: URL) {
        self.url = url
        isConnected = false
        request = URLRequest(url: url)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.receiver?.received(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.receiver?.received(text)
                case .data(let data):
                    self?.receiver?.received(data)
                @unknown default:
                    fatalError("New type of message was added by Apple into URLSessionWebSocketTask. Please, file an issue on https://github.com/web3swift-team/web3swift/issues. \(String(describing: message))")
                }
            }
        }
    }

    func setReceiver(_ receiver: WebSocketMessageReceiver) {
        self.receiver = receiver
    }

    func send(_ message: String) {
        webSocketTask.send(.string(message)) { error in
            if let error = error {
                self.receiver?.received(error)
            }
        }
    }

    func send(_ message: String) async throws {
        try await webSocketTask.send(.string(message))
    }

    func send(_ message: Data) {
        webSocketTask.send(.data(message)) { error in
            if let error = error {
                self.receiver?.received(error)
            }
        }
    }

    func send(_ message: Data) async throws {
        try await webSocketTask.send(.data(message))
    }

    func resume() {
        if webSocketTask.state == .canceling ||
            webSocketTask.state == .completed ||
            webSocketTask.closeCode != .invalid { return }
        webSocketTask.resume()
        isConnected = true
    }

    func cancel() {
        webSocketTask.cancel()
        isConnected = false
    }

    func connect() {
        resume()
    }

    func disconnect() {
        cancel()
    }

    func write(string: String, completion: (() -> Void)?) {
        webSocketTask.send(.string(string)) { [weak self] error in
            if let error = error {
                self?.receiver?.received(error)
            }
            completion?()
        }
    }
}
