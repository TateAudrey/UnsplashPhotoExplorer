//
//  UnsplashAPIClient.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/20/25.
//

import Foundation

/// Concrete Unsplash API client implementing networking calls.
final class UnsplashAPIClient: UnsplashAPIClientProtocol {
    
    private let session: URLSession
    private let apiKey: String
 
    //MARK: - Comment code below if using manual API key
    /// Initializes the client and reads the Unsplash API key from Info.plist.
    /// If missing, the app will crash with a clear message.
    init(session: URLSession = .shared) {
        self.session = session
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_KEY") as? String,
              !key.isEmpty else {
            fatalError("Unsplash API key not found in Info.plist")
        }
        self.apiKey = key
    }
    
    //MARK: - Uncomment code below and paste your API Key manually
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
    
    /// Convenience method to fetch 20 random photos by default.
    func fetchRandomPhotos() async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
        await fetchRandomPhotos(count: 40)
    }
    
    /// Fetches random photos from Unsplash API with a given count.
    func fetchRandomPhotos(count: Int = 40) async -> Result<(photos: [Photo], rate: RateLimitInfo?), UnsplashError> {
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
    
    /// Searches photos on Unsplash API based on query and pagination.
    func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async -> Result<(photos: [Photo], total: Int, rate: RateLimitInfo?), UnsplashError> {
        var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos")
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        guard let url = urlComponents?.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.unknown)
            }
            let rateLimitInfo = RateLimitInfo(from: httpResponse)
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let searchResponse = try decoder.decode(SearchPhotosResponse.self, from: data)
                return .success((photos: searchResponse.results, total: searchResponse.total, rate: rateLimitInfo))
                
            case 429:
                return .failure(.rateLimited(reset: rateLimitInfo.reset, limit: rateLimitInfo.limit, remaining: rateLimitInfo.remaining))
                
            default:
                let errorMsg = String(data: data, encoding: .utf8)
                return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMsg))
            }
        } catch {
            return .failure(.networkError(error))
        }
    }
}
