//
//  StoryStateStore.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

protocol StoryStateStoreProtocol: AnyObject {
    func markViewed(userID: String, storyID: String)
    func toggleLike(userID: String, storyID: String)
    func isViewed(userID: String, storyID: String) -> Bool
    func isLiked(userID: String, storyID: String) -> Bool
    
    func clearViewed()
    func clearLiked()
}

final class StoryStateStore: StoryStateStoreProtocol {
    private let defaultsKey = "StoryState"
    private var state: StoryState
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(StoryState.self, from: data) {
            self.state = decoded
        } else {
            self.state = StoryState(viewedIDs: [], likedIDs: [])
            persist()
        }
    }

    // MARK: - Public API

    func markViewed(userID: String, storyID: String) {
        let key = makeKey(userID: userID, storyID: storyID)
        if !state.viewedIDs.contains(key) {
            state.viewedIDs.insert(key)
            persist()
            print("Viewed: \(key)")
        }
    }
    
    func clearViewed() {
        state.viewedIDs.removeAll()
        persist()
        print("[Cleared all viewed stories")
    }

    func toggleLike(userID: String, storyID: String) {
        let key = makeKey(userID: userID, storyID: storyID)
        if state.likedIDs.contains(key) {
            state.likedIDs.remove(key)
            print("Unliked: \(key)")
        } else {
            state.likedIDs.insert(key)
            print("Liked: \(key)")
        }
        persist()
    }

    func isViewed(userID: String, storyID: String) -> Bool {
        state.viewedIDs.contains(makeKey(userID: userID, storyID: storyID))
    }

    func isLiked(userID: String, storyID: String) -> Bool {
        state.likedIDs.contains(makeKey(userID: userID, storyID: storyID))
    }
    
    func clearLiked() {
        state.likedIDs.removeAll()
        persist()
        print("Cleared all liked stories")
    }
    
    // MARK: - Helpers

    private func makeKey(userID: String, storyID: String) -> String {
        "\(userID)_\(storyID)"
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: defaultsKey)
        }
    }
}
