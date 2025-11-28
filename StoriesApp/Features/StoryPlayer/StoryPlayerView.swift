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
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Loading story")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                    case .failure(_):
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Failed to load image")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                        .onAppear {
                            print("Failed to load story - ID=\(viewModel.currentStory.id), url=\(viewModel.currentStory.imageURL)")
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .id(viewModel.currentStory.id)

                tapOverlay(geometry: geometry)
                
                VStack {
                    headerOverlay(geometry: geometry)
                    Spacer()
                    bottomOverlay(geometry: geometry)
                }
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

    // MARK: - Overlays
    
    private func headerOverlay(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color.black.opacity(1.0),
                    Color.black.opacity(0.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .allowsHitTesting(false)

            VStack(spacing: 4) {
                Text(viewModel.currentUser.name)
                    .font(.title3)
                    .foregroundColor(.white)

                Text(viewModel.currentStoryPositionText)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, geometry.safeAreaInsets.top + 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }        
        .padding(.top, geometry.safeAreaInsets.top + 72)

    }

    private func bottomOverlay(geometry: GeometryProxy) -> some View {
        HStack {
            Image(systemName: viewModel.isCurrentStoryViewed ? "eye.fill" : "eye.slash.fill")
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(viewModel.isCurrentStoryLiked ? .red : .white)
                .padding(12)
                .frame(maxWidth: .infinity)

            Spacer()

            likeButton
        }
        .padding(.bottom, geometry.safeAreaInsets.bottom + 24)
        .padding(.horizontal, 16)        
    }
    
    private var likeButton: some View {
        Button(action: {
            viewModel.toggleLike()
        }) {
            Image(systemName: viewModel.isCurrentStoryLiked ? "heart.fill" : "heart")
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(viewModel.isCurrentStoryLiked ? .red : .white)
                .padding(12)
        }
        .frame(maxWidth: .infinity)
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
    let stateStore = StoryStateStore()
    let vm = StoryPlayerViewModel(users: users, initialUserIndex: 0, initialStoryIndex: 0, stateStore: stateStore)
    StoryPlayerView(viewModel: vm)
}
