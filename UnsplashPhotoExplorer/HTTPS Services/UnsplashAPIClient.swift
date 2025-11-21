//
//  UnsplashAPIClient.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation

enum UnsplashError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case httpError(statusCode: Int, message: String?)
    case rateLimited(reset: Date?, limit: Int?, remaining: Int?)
    case decodingError(Error)
    case networkError(Error)
    case unknown
}

protocol SecretStore {
    func unsplashAPIKey() -> String?
}

struct RateLimitInfo {
    let limit: Int?
    let remaining: Int?
    let reset: Date?
    
    init(from response: HTTPURLResponse) {
        let h = response.allHeaderFields
        
        self.limit = Int((h["X-Ratelimit-Limit"] as? String) ?? "")
        self.remaining = Int((h["X-Ratelimit-Remaining"] as? String) ?? "")
        
        if let resetString = h["X-Ratelimit-Reset"] as? String,
           let seconds = TimeInterval(resetString) {
            self.reset = Date(timeIntervalSince1970: seconds)
        } else {
            self.reset = nil
        }
    }
}

struct SearchPhotosResponse: Codable {
    let total: Int
    let results: [Photo]
}

// MARK: - Protocol for testability

protocol UnsplashAPIClientProtocol {
    // Zero-argument overload used by ViewModel and tests
    func fetchRandomPhotos() async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError>
    // Explicit count overload
    func fetchRandomPhotos(count: Int) async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError>
    // Search API
    func searchPhotos(query: String, page: Int, perPage: Int) async -> Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError>
}

final class UnsplashAPIClient: UnsplashAPIClientProtocol {
    
    private let session: URLSession
    private let apiKey: String
 
    //Comment this code if the Secret.xconfig file does not work. Check README Documentation
    init(session: URLSession = .shared) {
        self.session = session
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_KEY") as? String,
              !key.isEmpty else {
            fatalError("Unsplash API key not found in Info.plist")
        }
        self.apiKey = key
    }
    
//Uncomment code below and paste your API Key manually
//    init(session: URLSession = .shared) {
//        self.session = session
//        
//        ///Enter your API Key here:
//        let manualKey = "YOUR_UNSPLASH_API_KEY_HERE"
//        
//        guard !manualKey.isEmpty else {
//            fatalError("""
//            Unsplash API key is missing!
//            Please open UnsplashAPIClient.swift and set:
//            let manualKey = "YOUR_UNSPLASH_API_KEY_HERE"
//            """)
//        }
//        
//        self.apiKey = manualKey
//    }
    
    // Zero-argument convenience that defaults to 20
    func fetchRandomPhotos() async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
        await fetchRandomPhotos(count: 20)
    }
    
    func fetchRandomPhotos(count: Int = 20) async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
        guard let url = URL(string: "https://api.unsplash.com/photos/random?count=\(count)") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                return .failure(.unknown)
            }
            
            let rate = RateLimitInfo(from: http)
            
            switch http.statusCode {
            case 200:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let photos = try decoder.decode([Photo].self, from: data)
                    return .success((photos: photos, rate: rate))
                } catch {
                    return .failure(.decodingError(error))
                }
                
            case 429:
                return .failure(.rateLimited(reset: rate.reset, limit: rate.limit, remaining: rate.remaining))
                
            default:
                let msg = String(data: data, encoding: .utf8)
                return .failure(.httpError(statusCode: http.statusCode, message: msg))
            }
            
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async -> Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError> {
        // Construct the URL with query parameters
        var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos")
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        guard let url = urlComponents?.url else {
            return .failure(.invalidURL)
        }
        
        // Prepare the request with authorization header
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            // Perform the network request
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.unknown)
            }
            let rateLimitInfo = RateLimitInfo(from: httpResponse)
            
            switch httpResponse.statusCode {
            case 200:
                // Decode the JSON response
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let searchResponse = try decoder.decode(SearchPhotosResponse.self, from: data)
                // Return photos array, total count, and rate info
                return .success((photos: searchResponse.results, total: searchResponse.total, rate: rateLimitInfo))
            case 429:
                // Rate limiting error
                return .failure(.rateLimited(reset: rateLimitInfo.reset, limit: rateLimitInfo.limit, remaining: rateLimitInfo.remaining))
            default:
                // Handle other HTTP errors
                let errorMsg = String(data: data, encoding: .utf8)
                return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMsg))
            }
        } catch {
            // Network or decoding failure
            return .failure(.networkError(error))
        }
    }
}

