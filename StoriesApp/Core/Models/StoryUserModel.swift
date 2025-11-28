//
//  StoryUserModel.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

///
/// Raw version of the model, used for parsing only,
/// this avoids handling the optionals later, while also adding the
/// option to ignore wrong entries without fully preventing app usage
///
struct RawStoryUser: Decodable {
    let id: String?
    let name: String?
    let avatarURL: String?
    let stories: [RawStory]?
}

struct StoryUser: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let avatarURL: URL
    let stories: [Story]
}
