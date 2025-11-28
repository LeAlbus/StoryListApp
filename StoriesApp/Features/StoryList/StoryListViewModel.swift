//
//  StoryListViewModel.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

@MainActor
final class StoryListViewModel: ObservableObject {
    @Published private(set) var users: [StoryUser] = []
    @Published private(set) var errorMessage: String?

    private let repository: StoriesRepositoryProtocol

    init(repository: StoriesRepositoryProtocol) {
        self.repository = repository
        loadUsers()
    }

    func loadUsers() {
        do {
            let loaded = try repository.loadUsers()
            users = loaded
            errorMessage = nil
        } catch {
            users = []
            errorMessage = "Failed to load user stories."
        }
    }
}
