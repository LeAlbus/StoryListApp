//
//  StoryModel.swift
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
struct RawStory: Decodable {
    let id: String?
    let imageURL: String?
}

struct Story: Identifiable, Codable, Hashable {
    let id: String
    let imageURL: URL
}
