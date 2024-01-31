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

protocol GithubContentServiceProtocol {
    func treeItemsForDirectory(path: String) -> AnyPublisher<[TreeItem], MoyaError>
    func fetchContent(url: String) -> AnyPublisher<Data, MoyaError>
}

class GithubContentService: GithubContentServiceProtocol {
    let provider = MoyaProvider<DecksService>()
    
    func treeItemsForDirectory(path: String) -> AnyPublisher<[TreeItem], MoyaError> {
        print("==== fetching tree items for dir: \(path)")
        return provider.requestPublisher(.dirContent(directory: path))
            .map {
                print("aaaa \(String(data: $0.data, encoding: .utf8))")
                return $0
            }.eraseToAnyPublisher()
            .map([TreeItem].self)
            .eraseToAnyPublisher()
    }
    
    func fetchContent(url: String) -> AnyPublisher<Data, MoyaError> {
        return provider.requestPublisher(.fileContent(url: url))
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
