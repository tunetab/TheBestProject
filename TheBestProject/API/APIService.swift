//
//  APIService.swift
//  TheBestProject
//
//  Created by Стажер on 31.01.2022.
//

import Foundation

struct TrackRequest: APIRequest {
    
    var postData: Data?
    
    typealias Response = [String: Track]
    
    var track: Track?
    
    var query: [String: String]
    
}
