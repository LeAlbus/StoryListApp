//
//  StoriesRepository.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import Foundation

protocol StoriesRepositoryProtocol {
    func loadUsers() throws -> [StoryUser]
}

enum StoriesRepositoryError: Error {
    case fileNotFound
    case invalidData
}

final class StoriesRepository: StoriesRepositoryProtocol {
    private let bundle: Bundle
    private let fileName: String

    init(bundle: Bundle = .main, fileName: String = "StoriesData") {
        self.bundle = bundle
        self.fileName = fileName
    }

    func loadUsers() throws -> [StoryUser] {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw StoriesRepositoryError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([StoryUser].self, from: data)
        } catch {
            //Handle excluding empty
            throw StoriesRepositoryError.invalidData
        }
    }
}
