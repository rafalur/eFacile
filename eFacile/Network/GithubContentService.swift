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
    func treeItemsForDirectory(dir: String) -> AnyPublisher<[TreeItem], MoyaError>
    func fetchContent(url: String) -> AnyPublisher<Data, MoyaError>
}

class GithubContentService: GithubContentServiceProtocol {
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
