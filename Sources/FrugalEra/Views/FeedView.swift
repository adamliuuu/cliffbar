import SwiftUI
import Foundation

// Make sure FeedItem and FeedViewModel are in scope
typealias FeedItemType = FeedItem.FeedItemType

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedFilter = 0
    @State private var showingComments = false
    @State private var showingAddPost = false
    
    private let filters = ["All", "Spending", "Health", "Tea"]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(filters.enumerated()), id: \.element) { index, filter in
                                    FilterPill(title: filter, isSelected: selectedFilter == index) {
                                        withAnimation(.spring()) {
                                            selectedFilter = index
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Feed Items
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.feedItems.filter { filterItem($0) }) { item in
                                FeedItemCard(item: item, viewModel: viewModel, showingComments: $showingComments)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // Plus Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddPost = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("The Tea ☕️")
            .refreshable {
                viewModel.fetchFeedItems()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
            .background(Color(.systemBackground))
            .sheet(isPresented: $showingComments) {
                CommentsView()
            }
            .overlay {
                if showingAddPost {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                showingAddPost = false
                            }
                        }
                }
            }
            .overlay {
                if showingAddPost {
                    AddPostModal()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            viewModel.fetchFeedItems()
        }
        .onChange(of: selectedFilter) { _ in
            viewModel.fetchFeedItems()
        }
    }
    
    private func filterItem(_ item: FeedItem) -> Bool {
        switch selectedFilter {
        case 0: return true
        case 1: return item.type == .spending || item.type == .purchase
        case 2: return item.type == .health
        case 3: return item.type == .social
        default: return true
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color(.systemBackground))
                        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 5)
                )
        }
    }
}

struct FeedItemCard: View {
    let item: FeedItem
    @ObservedObject var viewModel: FeedViewModel
    @Binding var showingComments: Bool
    @State private var likeScale: CGFloat = 1.0
    
    private var cardColor: Color {
        let index = abs(item.id.hashValue) % Theme.colors.feedColors.count
        return Theme.colors.feedColors[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(item.userImage)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(item.userName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Menu {
                    Button(action: {}) {
                        Label("Report", systemImage: "exclamationmark.triangle")
                    }
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Content
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.white)
            
            // Interaction Buttons
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        viewModel.toggleLike(for: item.id)
                        likeScale = 1.2
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                        likeScale = 1.0
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isLiked(itemId: item.id) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isLiked(itemId: item.id) ? .white : .white.opacity(0.8))
                            .scaleEffect(likeScale)
                        Text("\(item.likes)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Button(action: { showingComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(item.comments)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
} 