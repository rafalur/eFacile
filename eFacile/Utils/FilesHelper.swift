//
//  FilesHelper.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 20/01/2024.
//

import Foundation

class FilesHelper {
    
    static func allFilesInDocumentsDir() -> [String] {
        guard let documentDirectory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return []
        }
        
        // Get the directory contents urls (including subfolders urls)
        guard let directoryContents = try? FileManager.default.contentsOfDirectory(
            at: documentDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        return directoryContents.map { $0.lastPathComponent }
    }
}
