//
//  StoryModel.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

struct Story: Identifiable, Codable, Hashable {
    let id: String
    let imageURL: URL
}
