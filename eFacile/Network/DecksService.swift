//
//  DecksService.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 27/01/2024.
//

import Foundation
import Moya

enum DecksService {
    case dirContent(directory: String)
    case fileContent(url: String)
}



// MARK: - TargetType Protocol Implementation
extension DecksService: TargetType {
    var baseURL: URL { URL(string: "https://api.github.com/repos/rafalur/Piacere_decks/contents")! }
    var path: String {
        switch self {
        case .dirContent(let directory):
            return "/\(directory)"
        case .fileContent(url: let url):
            return url
        }
    }
    var method: Moya.Method {
        switch self {
        case .dirContent, .fileContent:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .dirContent:
            return .requestPlain
        case .fileContent:
            return .downloadDestination(DefaultDownloadDestination)
        }
        
    }
    var sampleData: Data {
        
        switch self {
        case .dirContent:
            return "Half measures are as bad as nothing at all.".utf8Encoded
        case .fileContent:
            return "sample_content".utf8Encoded
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data { Data(self.utf8) }
}


private let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    
}
