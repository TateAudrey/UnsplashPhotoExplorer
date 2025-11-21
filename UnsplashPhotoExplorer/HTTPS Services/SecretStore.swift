//
//  SecretStore.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//


/// Protocol to provide API key securely.
protocol SecretStore {
    func unsplashAPIKey() -> String?
}