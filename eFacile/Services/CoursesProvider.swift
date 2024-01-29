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
            .compactMap { items in
                guard let indexFileUrl = items.first(where: { item in item.name == Constants.indexFileName })?.downloadUrl else {
                    return nil
                }
                return URL(string: indexFileUrl)
            }
            .flatMap { [weak self] url -> AnyPublisher<Data, CoursesFetchError> in
                return self?.downloadFile(url: url) ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .compactMap { [weak self] data in
                guard let fileContent = String(data: data, encoding: .utf8) else { return nil }
                return self?.parseGroupName(content: fileContent)
            }
            .map { Course(id: courseName, name: $0) }
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
    
    private func parseGroupName(content: String) -> String? {
        let lines = content.components(separatedBy: .newlines)
                        
        return lines.toDict()[Constants.courseNameKey]
    }
}
