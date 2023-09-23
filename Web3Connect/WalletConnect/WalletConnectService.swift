//
//  WalletConnectService.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import UIKit
import BigInt
import SwiftUI
import Combine
import web3swift
import Web3Core
import WalletConnectSign
import WalletConnectRelay
import WalletConnectUtils
import WalletConnectPairing

/// Service that is responsible for all WalletConnect interactions.
/// There should be only one instance of WalletConnect per app instance but
/// there is no enforced limitation (e.g. through a singleton pattern).
/// At the moment of initialization connects to all
final class WalletConnectService: ObservableObject {

    static let `default` = WalletConnectService()

    static let metadata = AppMetadata(name: "SampleApp-iOS",
                                      description: "Example application using web3swift + WalletConnect V2.",
                                      url: "https://github.com/web3swift-team/web3swift",
                                      icons: ["https://github.com/web3swift-team/web3swift/blob/develop/web3swift-logo.png"])

    static var projectId: String? {
        guard let url = Bundle.main.url(forResource: ".walletConnectProjectId", withExtension: nil) else { return nil }
        return (try? String(contentsOf: url))?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Request handlers (RPC handlers)

    private lazy var ethSendTransactionRequestHandler: RequestHandler = {
        RequestHandler(filterBy: ["eth_sendTransaction"]) { request in
            // You can validate incoming transaction however you need
            // and in case of an invalid transaction return `reject` response without
            // user ever knowing about this transaction.

            let ethTransactionParams: [EthSendTransaction]? = try! request.decodeParams()
            let theActualParams = ethTransactionParams?.first

            /*
             validateTransaction(ethTransactionParams) { response in
                 // if response is valid then continue. Otherwise, reject.
                 guard response else {
                     self.reject(request, JSONRPCError.invalidParams)
                     return
                 }

                 // otherwise trigger a UI to ask user to sign transaction
                 requestListener(request)
             }
             */

            Task {
                if theActualParams != nil {
                    self.requestListener?(request)
                } else {
                    try! await self.reject(request, withError: JSONRPCError.invalidParams)
                }
            }
        }
    }()

    private lazy var methodHandlers: [RequestHandler] = [ethSendTransactionRequestHandler]

    private var publishers = Set<AnyCancellable>()

    /// Outside listener for pending requests.
    private var requestListener: ((Request) -> Void)?
    private var sessionProposalListener: ((Session.Proposal) -> Void)?

    private let signClient = Sign.instance
    private let pairClient = Pair.instance

    private(set) var sessions: [String: Session] = [:]

    private init() {
        signClient.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (proposal, context) in
                self?.sessionProposalListener?(proposal)
            }.store(in: &publishers)
        signClient.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] (request, context) in
                self.handleIncomingRequest(request)
            }.store(in: &publishers)
        signClient.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] status in
                switch status {
                case .disconnected:
                    NSLog("WalletConnect socket connection dropped.")
                    // Try to reconnect?
                default: break
                }
            }.store(in: &publishers)
        signClient.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] session in
                // You may also want to persist session data
                self.sessions[session.topic] = session
            }.store(in: &publishers)
        signClient.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] (topic, _ /*reason*/) in
                // You may also want to delete session data from persistent storage
                self.sessions.removeValue(forKey: topic)
            }.store(in: &publishers)
        signClient.sessionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] (topic, namespaces) in
                // topic and namespaces are incoming here and you should update your session object
            }.store(in: &publishers)
        signClient.sessionExtendPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] (topic, date) in
                // Show some UI to the user asking if session should be extended or not.
                // This publisher let's you know when DApp suggest to extend the lifetime of the session.
            }.store(in: &publishers)
        signClient.sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sessions in
                // Not sure yet what this does :) Do not remember the docs.
            }.store(in: &publishers)
    }

    deinit {
        disconnectFromAll()
    }

    func setRequestListener(_ requestListener: @escaping (Request) -> Void) {
        self.requestListener = requestListener
    }

    func setSessionProposalListener(_ sessionProposalListener: @escaping (Session.Proposal) -> Void) {
        self.sessionProposalListener = sessionProposalListener
    }

    // MARK: - General

    func approveProposal(_ proposal: Session.Proposal, _ addresses: [EthereumAddress]) async throws {
        var namespaces: [String : SessionNamespace] = [:]
        for (caip2Key, namespace) in proposal.requiredNamespaces {
            let accounts = addresses.compactMap { address in
                namespace.chains?.compactMap { Account(blockchain: $0, address: address.address) }
            }.flatMap { $0 }

            namespaces[caip2Key] = SessionNamespace(accounts: Set(accounts),
                                                    methods: namespace.methods,
                                                    events: namespace.events)
        }
        try await signClient.approve(proposalId: proposal.id, namespaces: namespaces)
    }

    func rejectProposal(_ proposal: Session.Proposal, _ rejectReason: RejectionReason) async throws {
        try await signClient.reject(proposalId: proposal.id, reason: rejectReason)
    }

    @MainActor
    func connect(_ uri: WalletConnectURI) {
        Task {
            do {
                try await self.connect(uri)
            } catch {
                NSLog("Failed to connect \(error.localizedDescription)")
            }
        }
    }

    /// Attempts to connect to given WalletConnectURI (e.g. if this URL was scanned from a QR code).
    func connect(_ uri: WalletConnectURI) async throws {
        try await pairClient.pair(uri: uri)
    }

    func disconnectFromAll() {
        Task {
            for session in sessions.values {
                try await disconnect(topic: session.topic)
            }
            sessions.removeAll()
        }
    }

    func disconnect(topic: String) async throws {
        try await pairClient.disconnect(topic: topic)
        try await signClient.disconnect(topic: topic)
    }

    // MARK: - Approve & Reject requests

    func approve<T: Codable>(_ request: Request, value: T) async throws {
        try await signClient.respond(topic: request.topic, requestId: request.id, response: .response(AnyCodable(value)))
    }

    func reject(_ request: Request, withError: Error? = nil, errorCode: Int = JSONRPCError.internalError.code) async throws {
        let error = JSONRPCError(code: errorCode, message: withError?.localizedDescription ?? "Rejected.")
        try await signClient.respond(topic: request.topic, requestId: request.id, response: .error(error))
    }

    private func handleIncomingRequest(_ request: Request) {
        methodHandlers.first { handler in
            handler.filter(request)
        }?.handle(request)
    }
}
