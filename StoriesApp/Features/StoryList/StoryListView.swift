//
//  StoryRowList.swift
//  StoriesApp
//
//  Created by Pedro Lopes on 28/11/25.
//

import SwiftUI

struct StoryListView: View {
    @StateObject private var viewModel: StoryListViewModel

    @State private var selectedUserIndex: Int = 0 
    @State private var isPresentingPlayer = false

    init(viewModel: StoryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Group {
                if !viewModel.users.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Stories")
                            .font(.title2.bold())

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                                    UserCarouselItemView(user: user)
                                        .onTapGesture {
                                            selectedUserIndex = index
                                            isPresentingPlayer = true
                                        }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 130)

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
                initialStoryIndex: 0
            )
            StoryPlayerView(viewModel: playerVM)
        }
    }
}

#Preview {
    let repo = StoriesRepository(bundle: .main, fileName: "stories")
    let vm = StoryListViewModel(repository: repo)
    return StoryListView(viewModel: vm)
}

