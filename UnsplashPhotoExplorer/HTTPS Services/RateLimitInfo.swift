//
//  RateLimitInfo.swift
//  UnsplashPhotoExplorer
//
//  Created by Audrey Chanakira on 11/21/25.
//

import Foundation

/// Struct to parse Unsplash API rate limit headers.
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
