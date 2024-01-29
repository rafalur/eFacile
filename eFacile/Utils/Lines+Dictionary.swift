//
//  Lines+Dictionary.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 29/01/2024.
//

import Foundation

extension Array where Element == String {
    func toDict() -> [String: String] {
        var resultDict: [String: String] = .init()
        
        let pattern = "\"(.*?)\"\\s*,\\s*\"(.*?)\""
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        self.forEach {
            if let match = regex.firstMatch(in: $0, options: [], range: NSRange(location: 0, length: $0.count)) {
                let key = String($0[Range(match.range(at: 1), in: $0)!])
                let value = String($0[Range(match.range(at: 2), in: $0)!])

                resultDict[key] = value
            }
        }
        return resultDict
    }
}
