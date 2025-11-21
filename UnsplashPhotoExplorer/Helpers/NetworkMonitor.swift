//
//  NetworkMonitor.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation
import Network
import SwiftUI
import Combine

/// A singleton class that monitors network connectivity status in real-time.
final class NetworkMonitor: ObservableObject {
    
    /// Shared instance for global access throughout the app.
    static let shared = NetworkMonitor()
    
    /// Network monitor from Apple's Network framework.
    private let monitor = NWPathMonitor()
    
    /// Dispatch queue for running the network monitor.
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    /// Published property indicating whether the device is connected to the internet.
    @Published var isConnected: Bool = true
    
    /// Private initializer to enforce singleton usage and start monitoring.
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                // Update the connectivity status on the main thread
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

