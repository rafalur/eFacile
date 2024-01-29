//
//  CoursesProvider.swift
//  eFacile
//
//  Created by Rafal Urbaniak on 29/01/2024.
//

import Foundation
import Combine
import Moya
import CombineMoya

enum CoursesFetchError: Error {
    case serviceConnectionFailure
    case fileDownloadFailure
}

class CoursesProvider {
    enum Constants {
        static let coursesDir = "groups"
        static let courseNameKey = "group_name"
        static let indexFileName = "index.txt"
        static let imageFileNameKey = "image_file_name"
        static let imageFileUrlNameKey = "image_file_url"
    }
    
    let ghContentService = GithubContentService()
    
    func fetchCourses() -> AnyPublisher<[Course], CoursesFetchError> {
        ghContentService.treeItemsForDirectory(dir: Constants.coursesDir)
            .mapError { _ in CoursesFetchError.serviceConnectionFailure }
            .map { $0.filter{ item in item.isDirectory} }
            .flatMap { dirs in dirs.publisher }
            .flatMap { [weak self] dir -> AnyPublisher<Course, CoursesFetchError> in
                print("fetch content of \(dir.name)")
                return self?.fetchCourse(courseName: dir.name) ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()
            
    }
    
    func fetchCourse(courseName: String) -> AnyPublisher <Course, CoursesFetchError> {
        return ghContentService.treeItemsForDirectory(dir: "\(Constants.coursesDir)/\(courseName)")
            .mapError { _ in CoursesFetchError.serviceConnectionFailure }
            .map { treeItems in treeItems.filter { $0.isFile } }
            .flatMap { [weak self] treeItems -> AnyPublisher<[String: String], CoursesFetchError> in
                return self?.courseInfoParams(fileItems: treeItems) ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .compactMap {
                guard let name = $0[Constants.courseNameKey] else {
                    return nil
                }
                
                let imageUrl = $0[Constants.imageFileUrlNameKey]
                
                return Course(id: courseName, name: name, imageUrl: imageUrl)
            }
            .eraseToAnyPublisher()
    }
    
    func courseInfoParams(fileItems: [TreeItem]) -> AnyPublisher<[String: String], CoursesFetchError> {
        guard let indexFileUrl = fileItems.first(where: { item in item.name == Constants.indexFileName })?.downloadUrl else {
            return Empty().eraseToAnyPublisher()
        }
        
        guard let url = URL(string: indexFileUrl) else {
            return Empty().eraseToAnyPublisher()
        }

        return downloadFile(url: url)
            .compactMap {
                guard let text = String(data: $0, encoding: .utf8) else {
                    return nil
                }
                
                var dict = text.components(separatedBy: .newlines).toDict()
                
                if let imageFileName = dict[Constants.imageFileNameKey], let matchingFileItem = fileItems.first(where: { $0.name == imageFileName }) {
                    dict.removeValue(forKey: imageFileName)
                    dict[Constants.imageFileUrlNameKey] = matchingFileItem.downloadUrl
                }
                                
                return dict
            }
            .eraseToAnyPublisher()
    }
    
    func downloadFile(url: URL) -> AnyPublisher<Data, CoursesFetchError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .mapError { _ in
                CoursesFetchError.fileDownloadFailure
            }
            .eraseToAnyPublisher()
    }
}
