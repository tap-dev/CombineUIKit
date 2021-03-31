//
//  Requests.swift
//  CombineUIKit
//
//  Created by Greg Price on 30/03/2021.
//

import Foundation
import Combine

enum API {
    
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func publisher(for request: URLRequest) -> AnyPublisher<Data, URLError> {
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

extension URLComponents {
    
    static func unsplash(path: String, queryItems: [String: String]) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = path
        components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components
    }
}

extension URLRequest {
    
    static func unsplash(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID iZtw8MF31vX7HRImIxwViLf8LnOBeESxKvNfbihdGHs", forHTTPHeaderField: "Authorization")
        return request
    }
    
    static func searchPhotos(query: String, perPage: Int = 20) -> URLRequest {
        let url = URLComponents.unsplash(path: "/search/photos", queryItems: ["query": query, "per_page": "\(perPage)"]).url!
        return .unsplash(url: url)
    }
}
