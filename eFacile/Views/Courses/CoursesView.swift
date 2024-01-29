//
//  DecksListViewe.swift
//  Sentences
//
//  Created by Rafal Urbaniak on 16/01/2024.
//

import Foundation
import SwiftUI

struct CoursesView: View {
    
    @StateObject var viewModel: CoursesViewModel
    
    var body: some View {
        
        VStack (spacing: 0) {
            Rectangle()
                .frame(height: 10)
                .foregroundColor(Theme.colors.background)
                .background(Theme.colors.background)
                .compositingGroup()
                .shadow(color: .black.opacity(0.2), radius: 5)
                .zIndex(1)
            
            
            if viewModel.courses.isEmpty {
                ProgressView().padding(.top)
            } else {
                coursesScrollView
            }
            Spacer()

        }
        .background(Theme.colors.background)
    }
    
    var coursesScrollView: some View {
        ScrollView {
            VStack(spacing: 40) {
                ForEach(viewModel.courses, id: \.id) { course in
                    NavigationLink.init(value: 1) {
                        CourseView(course: course) {
                            print("tapped")
                        }
                    }
                }
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
        }
        .refreshable {
            viewModel.load()
        }
    }
}

struct CourseView: View {
    let course: Course
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(course.name)")
                .multilineTextAlignment(.leading)
                .font(Theme.fonts.bold(18))
        }
        .foregroundColor(Theme.colors.foreground)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.colors.backgroundSecondary)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.5), radius: 15, x: 15, y: 15)
    }
}
