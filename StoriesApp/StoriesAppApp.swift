//
//  StoriesAppApp.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import SwiftUI

@main
struct StoriesAppApp: App {
    var body: some Scene {
        WindowGroup {
            // Add initial view
            // check tutorial
            let stateStore = StoryStateStore()
            let repository = StoriesRepository()
            let viewModel = StoryListViewModel(repository: repository)

            StoryListView(viewModel: viewModel, stateStore: stateStore)
        }
    }
}
