//
//  GithubContentService.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 28/01/2024.
//

import Foundation
import Moya
import CombineMoya
import Combine

class GithubContentService{
    let provider = MoyaProvider<DecksService>()
    
    func treeItemsForDirectory(dir: String) -> AnyPublisher<[TreeItem], MoyaError> {
       return provider.requestPublisher(.dirContent(directory: dir))
            .map([TreeItem].self)
            .eraseToAnyPublisher()
    }
    
    func fetchContent(url: String) -> AnyPublisher<Data, MoyaError> {
        return provider.requestPublisher(.fileContent(url: url))
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}

struct TreeItem: Codable {
    let name: String
    let path: String
    let type: String
    let downloadUrl: String?
    
    var isDirectory: Bool {
        type == "dir"
    }
    
    var isFile: Bool {
        type == "file"
    }
    
    private enum CodingKeys : String, CodingKey {
        case name, path, type, downloadUrl = "download_url"
    }
}

struct Course {
    let id: String
    let name: String
    let imageUrl: String?
}
