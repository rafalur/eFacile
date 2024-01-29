//
//  TreeItem.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 29/01/2024.
//

import Foundation

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
