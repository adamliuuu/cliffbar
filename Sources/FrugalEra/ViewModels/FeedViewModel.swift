import Foundation

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    private var likedItems: Set<UUID> = []
    
    func fetchFeedItems() {
        isLoading = true
        
        // Simulated data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.feedItems = [
                FeedItem(userName: "John", userImage: "👨", description: "Just got a great deal on coffee beans!", type: .purchase),
                FeedItem(userName: "Sarah", userImage: "👩", description: "Morning run completed! 🏃‍♀️", type: .health),
                FeedItem(userName: "Mike", userImage: "👨‍🦰", description: "Found this amazing thrift store!", type: .social),
                FeedItem(userName: "Emma", userImage: "👩‍🦰", description: "Meal prepped for the week, saved $50!", type: .spending)
            ]
            self.isLoading = false
        }
    }
    
    func toggleLike(for itemId: UUID) {
        if likedItems.contains(itemId) {
            likedItems.remove(itemId)
            if let index = feedItems.firstIndex(where: { $0.id == itemId }) {
                feedItems[index].likes -= 1
            }
        } else {
            likedItems.insert(itemId)
            if let index = feedItems.firstIndex(where: { $0.id == itemId }) {
                feedItems[index].likes += 1
            }
        }
    }
    
    func isLiked(itemId: UUID) -> Bool {
        likedItems.contains(itemId)
    }
} 