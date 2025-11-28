//
//  UserIconView.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import SwiftUI

struct UserCarouselItemView: View {
    let user: StoryUser
    let hasUnseenStories: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if hasUnseenStories {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple)
                        .frame(width: 90, height: 90)
                }
                
                AsyncImage(url: user.avatarURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Color.gray.opacity(0.3)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.title2)
                            )
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray)
                                .frame(width: 80, height: 80)
                            ProgressView()
                        }
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Text("\(user.name)")
                .font(.callout)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 90)
    }

}

#Preview {
    let mock = StoryUser(
        id: "test",
        name: "Alice",
        avatarURL: URL(string: "https://picsum.photos/id/10/200/200")!,
        stories: [
            Story(id: "11", imageURL: URL(string: "https://picsum.photos/id/11/540/960")!),
            Story(id: "11", imageURL: URL(string: "https://picsum.photos/id/11/540/960")!),
            Story(id: "11", imageURL: URL(string: "https://picsum.photos/id/11/540/960")!),
        ]
    )
    UserCarouselItemView(user: mock, hasUnseenStories: true)
        .padding()
}
