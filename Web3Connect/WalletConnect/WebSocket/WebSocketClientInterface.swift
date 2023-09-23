//
//  WebSocketClientInterface.swift
//  Web3Connect
//
//  Created by JeneaVranceanu on 23.09.2023.
//

import Foundation

/// A protocol for receiving websocket events from a WebSocket client.
public protocol WebSocketMessageReceiver: AnyObject {
    /// Called when the websocket connection is established.
    func connected()

    /// Called when the websocket connection is closed.
    func disconnected()

    /// Called when a text message is received over the websocket connection.
    /// - Parameter message: The text message that was received.
    func received(_ message: String)

    /// Called when a binary message is received over the websocket connection.
    /// - Parameter message: The binary message that was received.
    func received(_ message: Data)

    /// Called when an error occurs while receiving a websocket message.
    /// - Parameter error: The error that occurred.
    func received(_ error: Error)
}

public protocol WebSocketClientInterface {
    /// URL of the WebSocket server
    var url: URL { get }
    /// Internal session used by this WebSocket client
    var session: URLSession { get }
    /// Send a message to the WebSocket server
    func send(_ message: String)
    /// Send a message to the WebSocket server
    func send(_ message: String) async throws
    /// Send a message to the WebSocket server
    func send(_ message: Data)
    /// Send a message to the WebSocket server
    func send(_ message: Data) async throws
    /// Sets message receiver for the incoming messages
    func setReceiver(_ receiver: WebSocketMessageReceiver)
    /// Resumes or starts the WebSocket connection
    func resume()
    /// Closes the WebSocket connection. Calling `resume` will have no effect after this call.
    func cancel()
}
