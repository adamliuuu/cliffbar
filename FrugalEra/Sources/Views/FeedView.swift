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
                        ForEach(viewModel.feedItems.filter { filterItem($0) }) { item in
                            FeedItemCard(item: item, viewModel: viewModel, showingComments: $showingComments)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
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

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(1...5, id: \.self) { _ in
                        CommentRow()
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

struct CommentRow: View {
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
                Text("User Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("This is a sample comment that could be quite long and span multiple lines if needed.")
                    .font(.subheadline)
                Text("2h ago")
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