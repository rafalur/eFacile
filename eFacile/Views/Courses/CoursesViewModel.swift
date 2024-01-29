//
//  DecksListViewModel.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation
import Combine

class CoursesViewModel: ObservableObject {
    private let coursesProvider: CoursesProvider
    
    @Published var courses = [Course]()
    private var loadTriggerSubject = PassthroughSubject<Void, Never>()
    
    var subscriptions: Set<AnyCancellable> = .init()
        
    init(coursesProvider: CoursesProvider = CoursesProvider()) {
        self.coursesProvider = coursesProvider
        
        setupSubscriptions()
        
        load()
    }
    
    private func setupSubscriptions() {
        loadTriggerSubject
            .receive(on: DispatchQueue.global())
            .flatMap { [coursesProvider] _ in
                coursesProvider.fetchCourses()
            }
            .catch { _ in return Just([Course]()) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$courses)
    }
    
    func load() {
        loadTriggerSubject.send()
    }
}
