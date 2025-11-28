//
//  StoryRowList.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import SwiftUI

struct StoryListView: View {
    @StateObject private var viewModel: StoryListViewModel
    private let stateStore: StoryStateStoreProtocol

    @State private var selectedUserIndex: Int = 0 
    @State private var isPresentingPlayer = false
    @State private var viewedVersion: Int = 0

    init(viewModel: StoryListViewModel, stateStore: StoryStateStoreProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.stateStore = stateStore
    }

    var body: some View {
        NavigationView {
            Group {
                if !viewModel.users.isEmpty {
                    VStack(alignment: .center, spacing: 16) {
                        Text("Stories")
                            .font(.title2.bold())

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                                    let hasUnseenStories = user.stories.contains { story in
                                        !stateStore.isViewed(userID: user.id, storyID: story.id)
                                    }

                                    UserCarouselItemView(
                                        user: user,
                                        hasUnseenStories: hasUnseenStories
                                    )
                                    .onTapGesture {
                                        selectedUserIndex = index
                                        isPresentingPlayer = true
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 130)
                        .id(viewedVersion)  
                        
                        HStack(spacing: 12) {
                            Button("Clear viewed") {
                                stateStore.clearViewed()
                                viewedVersion &+= 1 
                            }
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.1))
                            )

                            Button("Clear likes") {
                                stateStore.clearLiked()
                            }
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.1))
                            )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.loadUsers()
                        }
                    }
                } else {
                    ProgressView("Loading stories…")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $isPresentingPlayer) {
            let playerVM = StoryPlayerViewModel(
                users: viewModel.users,
                initialUserIndex: selectedUserIndex,
                initialStoryIndex: 0,
                stateStore: stateStore
            )
            StoryPlayerView(viewModel: playerVM)
        }
    }
}

#Preview {
    let repo = StoriesRepository(bundle: .main, fileName: "stories")
    let stateStore = StoryStateStore()
    let vm = StoryListViewModel(repository: repo)
    StoryListView(viewModel: vm, stateStore: stateStore)
}

