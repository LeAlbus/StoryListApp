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
            print("JSON file not found.")
            throw StoriesRepositoryError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        
        let rawUsers: [RawStoryUser]
        do {
            let decoder = JSONDecoder()
            rawUsers = try decoder.decode([RawStoryUser].self, from: data)
        } catch {
            print("Decoding error:", error)
            throw StoriesRepositoryError.invalidData
        }
        
        print("Succesfully loaded stories data")
        return mapRawUsers(rawUsers)
    }
    
    //MARK: - Raw response handling
    
    private func mapRawUsers(_ rawUsers: [RawStoryUser]) -> [StoryUser] {
        var result: [StoryUser] = []
        var usedUserIDs = Set<String>()
        
        for raw in rawUsers {
            guard let idRaw = raw.id?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !idRaw.isEmpty else {
                print("Ignoring user with missing/empty id - Name = \(raw.name ?? "nil") Avatar = \(raw.avatarURL ?? "nil")")

                continue
            }
            
            guard !usedUserIDs.contains(idRaw) else {
                print("Ignoring user for id '\(idRaw)' - Duplicated ID")
                continue
            }
            
            guard let name = raw.name,
                  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let avatarString = raw.avatarURL,
                  let avatarURL = URL(string: avatarString)
            else {
                print("Ignoring user '\(idRaw)' - invalid name or avatar URL - name='\(raw.name ?? "nil")' avatarURL='\(raw.avatarURL ?? "nil")'")

                continue
            }
            
            let validStories = mapRawStories(raw.stories ?? [], userID: raw.id)
            guard !validStories.isEmpty else {
                print("Ignoring user '\(idRaw)' - no valid stories.")

                continue
            }
            
            let user = StoryUser(
                id: idRaw,
                name: name,
                avatarURL: avatarURL,
                stories: validStories
            )
            
            usedUserIDs.insert(idRaw)
            result.append(user)
        }
        
        return result
    }
    
    private func mapRawStories(_ rawStories: [RawStory], userID: String?) -> [Story] {
        var stories: [Story] = []
        var usedStoryIDs = Set<String>()
        
        for raw in rawStories {
            guard let idRaw = raw.id?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !idRaw.isEmpty else {
                print("Ignoring story with missing/empty id - user '\(userID ?? "nil ID")'. imageURL='\(raw.imageURL ?? "nil")'")
                continue
            }
            
            guard !usedStoryIDs.contains(idRaw) else {
                print("Ignoring story '\(idRaw)' - user '\(userID ?? "nil ID")' - duplicated")
                continue
            }
            
            guard let urlString = raw.imageURL,
                  let url = URL(string: urlString) else {
                print("Ignoring story '\(idRaw)' - user '\(userID ?? "nil ID")' - invalid imageURL = '\(raw.imageURL ?? "nil")'")

                continue
            }
            
            stories.append(
                Story(id: idRaw, imageURL: url)
            )
            usedStoryIDs.insert(idRaw)
        }
        
        return stories
    }
}

