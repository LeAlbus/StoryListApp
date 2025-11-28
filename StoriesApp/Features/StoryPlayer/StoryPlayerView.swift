//
//  StoryPlayerView.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import SwiftUI

struct StoryPlayerView: View {
    @ObservedObject var viewModel: StoryPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                AsyncImage(url: viewModel.currentStory.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width,
                                   maxHeight: geometry.size.height)
                    case .empty:
                        ProgressView()
                    case .failure(_):
                        VStack {
                            Image(systemName: "wifi.slash")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Failed to load image")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }

                tapOverlay(geometry: geometry)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        handleDrag(value)
                    }
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Navigation

    @ViewBuilder
    private func tapOverlay(geometry: GeometryProxy) -> some View {
        let width = geometry.size.width

        HStack(spacing: 0) {
            Color.clear
                .contentShape(Rectangle())
                .frame(width: width / 3)
                .onTapGesture {
                    viewModel.goToPreviousStory()
                }

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.goToNextStory()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func handleDrag(_ value: DragGesture.Value) {
        let translation = value.translation
        let threshold: CGFloat = 40

        if abs(translation.height) > abs(translation.width) {
            if translation.height > threshold {
                dismiss()
            }
        } else {
            if translation.width < -threshold {
                viewModel.goToNextUser()
            } else if translation.width > threshold {
                viewModel.goToPreviousUser()
            }
        }
    }
}

#Preview {
    let users = [
        StoryUser(
            id: "user_001",
            name: "Andre",
            avatarURL: URL(string: "https://picsum.photos/id/10/200/200")!,
            stories: [
                Story(id: "110", imageURL: URL(string: "https://picsum.photos/id/110/540/960")!),
                Story(id: "120", imageURL: URL(string: "https://picsum.photos/id/120/800/1400")!)
            ]
        ),
        StoryUser(
            id: "user_002",
            name: "Billy",
            avatarURL: URL(string: "https://picsum.photos/id/20/200/200")!,
            stories: [
                Story(id: "210", imageURL: URL(string: "https://picsum.photos/id/210/540/960")!)
            ]
        )
    ]

    let vm = StoryPlayerViewModel(users: users, initialUserIndex: 0, initialStoryIndex: 0)
    return StoryPlayerView(viewModel: vm)
}
