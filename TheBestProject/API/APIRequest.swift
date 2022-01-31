//
//  APIRequest.swift
//  TheBestProject
//
//  Created by Стажер on 31.01.2022.
//

import Foundation

protocol APIRequest {
    associatedtype Response
    
    var request: URLRequest { get }
    var postData: Data? { get }
    var query: [String: String] { get }
}

extension APIRequest {
    var host: String { "itunes.apple.com/search" }
    var data: Data? { nil }
}

extension APIRequest {
    var request: URLRequest {
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value)}
        
        var request = URLRequest(url: urlComponents.url!)
        
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        return request
    }
}

enum APIRequestError: Error {
    case itemsNotFound
    case requestFailed
}

extension APIRequest where Response: Decodable {
    func send() async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpresponse = response as? HTTPURLResponse,
              httpresponse.statusCode == 200 else {
                  throw APIRequestError.itemsNotFound
              }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded
    }
    
}
