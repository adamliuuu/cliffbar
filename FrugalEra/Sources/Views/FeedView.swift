import SwiftUI
import Foundation

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedFilter = 0
    @State private var showingComments = false
    
    private let filters = ["All", "Spending", "Health", "Tea"]
    
    var body: some View {
        NavigationView {
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
                        ForEach(Array(viewModel.feedItems.filter { filterItem($0) }.enumerated()), id: \.element.id) { index, item in
                            FeedItemCard(item: item, viewModel: viewModel, showingComments: $showingComments, index: index)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Feed")
            .refreshable {
                viewModel.fetchFeedItems()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.colors.background.opacity(0.8))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
            .background(Theme.colors.background)
            .sheet(isPresented: $showingComments) {
                CommentsView()
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
    let index: Int
    
    private var cardColor: Color {
        Theme.colors.feedColors[index % Theme.colors.feedColors.count]
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
                            .foregroundColor(.black)
                    )
                
                VStack(alignment: .leading) {
                    Text(item.userName)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.8))
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
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            
            // Content
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.black)
            
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
                            .foregroundColor(viewModel.isLiked(itemId: item.id) ? .black : .black.opacity(0.8))
                            .scaleEffect(likeScale)
                        Text("\(item.likes)")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                
                Button(action: { showingComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.black.opacity(0.8))
                        Text("\(item.comments)")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                
                Button(action: {
                    viewModel.currentPostId = item.id
                    viewModel.showingFriendSelector = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Add Friends")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // Selected Friends
            if !viewModel.getSelectedFriends(for: item.id).isEmpty {
                HStack {
                    Spacer()
                    Text("with " + viewModel.getSelectedFriends(for: item.id).joined(separator: " and "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $viewModel.showingFriendSelector) {
            FriendSelectorView(viewModel: viewModel)
        }
    }
}

struct FriendSelectorView: View {
    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.availableFriends, id: \.self) { friend in
                    Button(action: {
                        if let postId = viewModel.currentPostId {
                            viewModel.toggleFriendSelection(for: postId, friendName: friend)
                        }
                    }) {
                        HStack {
                            Text(friend)
                            Spacer()
                            if let postId = viewModel.currentPostId,
                               viewModel.isFriendSelected(for: postId, friendName: friend) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    
    // Sample comments for different types of posts
    private let comments = [
        Comment(userName: "Alex Smith", text: "That's such a good deal! I've been looking for something similar but everything's so expensive rn 😭", timeAgo: "2h ago"),
        Comment(userName: "Sam Chen", text: "Pro tip: Check out the clearance section next time! I got mine for 30% off", timeAgo: "3h ago"),
        Comment(userName: "Jordan Taylor", text: "Was this worth it? I'm debating getting one too but trying to be more mindful of spending", timeAgo: "4h ago"),
        Comment(userName: "Riley Patel", text: "OMG I wanted to buy this! Where did you find it?", timeAgo: "5h ago"),
        Comment(userName: "Morgan Lee", text: "You can find similar items at thrift stores for way less! Just saying 💅", timeAgo: "6h ago"),
        Comment(userName: "Casey Wong", text: "Remember to check if you really need it before buying! I've been trying to follow the 24-hour rule", timeAgo: "7h ago"),
        Comment(userName: "Jamie Rodriguez", text: "That's actually a pretty good price compared to what I've seen lately", timeAgo: "8h ago"),
        Comment(userName: "Taylor Kim", text: "I got something similar last month and it's been worth every penny!", timeAgo: "9h ago")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(comments, id: \.userName) { comment in
                        CommentRow(comment: comment)
                    }
                }
                
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        newComment = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct Comment: Identifiable {
    let id = UUID()
    let userName: String
    let text: String
    let timeAgo: String
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("👤")
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(comment.text)
                    .font(.subheadline)
                Text(comment.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
} 