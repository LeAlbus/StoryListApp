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
    @Published var errorMessage: String?

    private let repository: StoriesRepositoryProtocol
    private var currentPage: Int = 0
    private var isLoadingPage = false
    
    init(repository: StoriesRepositoryProtocol) {
        self.repository = repository
        loadInitialPage()
    }

    func loadInitialPage() {
        currentPage = 0
        do {
            let baseUsers = try repository.loadUsers()
            let pageUsers = reindexedUsers(from: baseUsers, page: currentPage)
            self.users = pageUsers
        } catch {
            errorMessage = "Failed to load stories."
            print("Error loading users: \(error)")
        }
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard !isLoadingPage else { return }

        let thresholdIndex = users.count - 3
        guard currentIndex >= thresholdIndex else { return }

        isLoadingPage = true
        currentPage += 1

        do {
            let baseUsers = try repository.loadUsers()
            let nextPageUsers = reindexedUsers(from: baseUsers, page: currentPage)
            users.append(contentsOf: nextPageUsers)
        } catch {
            print("Error loading next page: \(error)")
        }

        isLoadingPage = false
    }

    // MARK: - Helpers

    private func reindexedUsers(from baseUsers: [StoryUser], page: Int) -> [StoryUser] {
        baseUsers.map { user in
            let newUserID = "\(user.id)#\(page)"

            let newStories: [Story] = user.stories.map { story in
                let newStoryID = "\(story.id)#\(page)"
                return Story(
                    id: newStoryID,
                    imageURL: story.imageURL
                )
            }

            return StoryUser(
                id: newUserID,
                name: user.name,
                avatarURL: user.avatarURL,
                stories: newStories
            )
        }
    }
}
