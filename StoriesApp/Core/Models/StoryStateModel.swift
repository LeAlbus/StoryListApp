//
//  StoryStateModel.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

struct StoryState: Codable {
    var seenStoryIDs: Set<String>
    var likedStoryIDs: Set<String>
}
