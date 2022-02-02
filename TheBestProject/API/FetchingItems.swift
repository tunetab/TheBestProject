//
//  FetchingItems.swift
//  TheBestProject
//
//  Created by Стажер on 01.02.2022.
//

import Foundation

struct SearchResponse: Codable {
    let results: [Track]
}

class StoreItemController {
    enum StoreItemError: Error, LocalizedError {
        case itemsNotFound
        case imageDataMissing
    }
    
    func fetchItems(matching query: [String: String]) async throws -> [Track] {
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.itemsNotFound
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
        

        return searchResponse.results
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.imageDataMissing
        }

        guard let image = UIImage(data: data) else {
            throw StoreItemError.imageDataMissing
        }
        
        return image
    }
}
