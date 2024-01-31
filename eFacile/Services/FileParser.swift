//
//  FileParser.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 31/01/2024.
//

import Foundation


struct PairsWithHeder {
    let header: String
    let pairs: [String: String]
}


protocol FileParserProtocol {
    func parseCSV(fileContent: String) -> PairsWithHeder
    func parseSingleInlineItems(fileContent: String) -> [String]
}

class FileParser: FileParserProtocol {
    func parseCSV(fileContent: String) -> PairsWithHeder {
        var lines = fileContent.components(separatedBy: .newlines)
        
        let header = lines.removeFirst().replacingOccurrences(of: "\"", with: "")
        
        let pattern = "\"(.*?)\"\\s*,\\s*\"(.*?)\""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        var pairs: [String: String] = .init()
        
        lines.forEach {
            if let match = regex.firstMatch(in: $0, options: [], range: NSRange(location: 0, length: $0.count)) {
                let key = String($0[Range(match.range(at: 1), in: $0)!])
                let value = String($0[Range(match.range(at: 2), in: $0)!])

                pairs[key] = value
            }
        }
        
        return .init(header: header, pairs: pairs)
    }
    
    func parseSingleInlineItems(fileContent: String) -> [String] {
        let lines = fileContent.components(separatedBy: .newlines)
        return lines.map { $0.replacingOccurrences(of: "\"", with: "") }
    }
}
