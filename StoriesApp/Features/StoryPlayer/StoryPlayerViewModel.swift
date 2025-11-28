//
//  StoryPlayerViewModel.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

final class StoryPlayerViewModel: ObservableObject {
    @Published private(set) var currentUserIndex: Int
    @Published private(set) var currentStoryIndex: Int

    let users: [StoryUser]

    init(users: [StoryUser], initialUserIndex: Int, initialStoryIndex: Int = 0) {
        self.users = users

        guard !users.isEmpty else {
            self.currentUserIndex = 0
            self.currentStoryIndex = 0
            return
        }

        let safeUserIndex = min(max(initialUserIndex, 0), users.count - 1)
        let storiesCount = users[safeUserIndex].stories.count

        let safeStoryIndex: Int
        if storiesCount > 0 {
            safeStoryIndex = min(max(initialStoryIndex, 0), storiesCount - 1)
        } else {
            safeStoryIndex = 0
        }

        self.currentUserIndex = safeUserIndex
        self.currentStoryIndex = safeStoryIndex
    }

    var currentUser: StoryUser {
        users[currentUserIndex]
    }

    var currentStory: Story {
        currentUser.stories[currentStoryIndex]
    }

    // MARK: - Navegação entre stories

    func goToNextStory() {
        let stories = currentUser.stories
        guard !stories.isEmpty else { return }

        if currentStoryIndex + 1 < stories.count {
            currentStoryIndex += 1
        } else {
            goToNextUser(resetStoryIndex: true)
        }
    }

    func goToPreviousStory() {
        let stories = currentUser.stories
        guard !stories.isEmpty else { return }

        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
        } else {
            goToPreviousUser(goToLastStory: true)
        }
    }

    // MARK: - Navegação entre usuários

    func goToNextUser(resetStoryIndex: Bool = true) {
        guard currentUserIndex + 1 < users.count else { return }
        currentUserIndex += 1
        if resetStoryIndex {
            currentStoryIndex = 0
        } else {
            currentStoryIndex = min(currentStoryIndex, currentUser.stories.count - 1)
        }
    }

    func goToPreviousUser(goToLastStory: Bool = false) {
        guard currentUserIndex > 0 else { return }
        currentUserIndex -= 1

        if goToLastStory {
            currentStoryIndex = max(currentUser.stories.count - 1, 0)
        } else {
            currentStoryIndex = min(currentStoryIndex, currentUser.stories.count - 1)
        }
    }
}
