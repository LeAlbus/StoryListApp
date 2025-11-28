//
//  StoryUserModel.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

struct StoryUser: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let avatarURL: URL
    let stories: [Story]
}
