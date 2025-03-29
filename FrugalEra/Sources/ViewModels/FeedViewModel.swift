import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var likedItems: Set<UUID> = []
    @Published var selectedFriends: [UUID: Set<String>] = [:] // Maps post ID to set of friend names
    @Published var showingFriendSelector = false
    @Published var currentPostId: UUID?
    
    // Sample friends list
    let availableFriends = [
        "Brooke Xu",
        "Nicole Deng",
        "Ziya Momin",
        "Adam Liu",
        "Joe Fisherman",
        "Bennett Zeus"
    ]
    
    func toggleFriendSelection(for postId: UUID, friendName: String) {
        if selectedFriends[postId] == nil {
            selectedFriends[postId] = []
        }
        
        if selectedFriends[postId]?.contains(friendName) == true {
            selectedFriends[postId]?.remove(friendName)
        } else {
            selectedFriends[postId]?.insert(friendName)
        }
    }
    
    func isFriendSelected(for postId: UUID, friendName: String) -> Bool {
        selectedFriends[postId]?.contains(friendName) ?? false
    }
    
    func getSelectedFriends(for postId: UUID) -> [String] {
        Array(selectedFriends[postId] ?? [])
    }
    
    func fetchFeedItems() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Sample data
            self.feedItems = [
                FeedItem(
                    id: UUID(),
                    title: "Joe is in their frugal era 💅",
                    description: "Just started a new budget and saved $200 this week! Living that broke girl lifestyle fr fr",
                    timestamp: Date().addingTimeInterval(-3600),
                    type: .spending,
                    likes: Int.random(in: 1...10),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Joe"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Energy Drink Addiction Alert ⚡️",
                    description: "Nicole just bought their 4th Red Bull of the day... at this point they're probably vibrating through walls",
                    timestamp: Date().addingTimeInterval(-7200),
                    type: .purchase,
                    likes: Int.random(in: 1...10),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Nicole"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Health Check! 🏥",
                    description: "Adam has a doctor's appointment tomorrow - sending good vibes! Don't forget to check in on your friends",
                    timestamp: Date().addingTimeInterval(-86400),
                    type: .health,
                    likes: Int.random(in: 1...10),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Adam"
                ),
                FeedItem(
                    id: UUID(),
                    title: "New Drip Alert 👀",
                    description: "Ziya just bought something expensive at Best Buy - check out their new setup!",
                    timestamp: Date().addingTimeInterval(-172800),
                    type: .purchase,
                    likes: Int.random(in: 1...10),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Ziya"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Late Night Shopping Alert 🚨",
                    description: "Brooke made an impulse purchase at Target at 2 AM... we've all been there bestie",
                    timestamp: Date().addingTimeInterval(-259200),
                    type: .purchase,
                    likes: Int.random(in: 1...10),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Brooke"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Touch Grass Alert 🌱",
                    description: "Bennett just subscribed to their 5th streaming service... maybe go outside?",
                    timestamp: Date().addingTimeInterval(-345600),
                    type: .purchase,
                    likes: Int.random(in: 1...10),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Bennett"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Caffeine Addiction Check ☕️",
                    description: "Casey's 3rd Starbucks run today... someone's crashing hard later",
                    timestamp: Date().addingTimeInterval(-432000),
                    type: .purchase,
                    likes: Int.random(in: 80...350),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Casey"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Suspicious Transaction 🕵️‍♀️",
                    description: "Jamie just made a purchase at 3 AM with a VPN... we're not judging, we're just concerned",
                    timestamp: Date().addingTimeInterval(-518400),
                    type: .purchase,
                    likes: Int.random(in: 90...400),
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Jamie"
                )
            ]
            
            // Adjust likes to be at most 2 less than comments
            for i in 0..<self.feedItems.count {
                let comments = self.feedItems[i].comments
                let currentLikes = self.feedItems[i].likes
                if currentLikes < comments - 2 {
                    self.feedItems[i] = FeedItem(
                        id: self.feedItems[i].id,
                        title: self.feedItems[i].title,
                        description: self.feedItems[i].description,
                        timestamp: self.feedItems[i].timestamp,
                        type: self.feedItems[i].type,
                        likes: comments - 2,
                        comments: comments,
                        userImage: self.feedItems[i].userImage,
                        userName: self.feedItems[i].userName
                    )
                }
            }
            
            self.isLoading = false
        }
    }
    
    func toggleLike(for itemId: UUID) {
        if likedItems.contains(itemId) {
            likedItems.remove(itemId)
        } else {
            likedItems.insert(itemId)
        }
    }
    
    func isLiked(itemId: UUID) -> Bool {
        likedItems.contains(itemId)
    }
}

struct FeedItem: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let timestamp: Date
    let type: FeedItemType
    let likes: Int
    let comments: Int
    let userImage: String
    let userName: String
    var selectedFriends: [String] = [] // New property for selected friends
}

enum FeedItemType {
    case spending
    case purchase
    case health
    case achievement
    case social
    case recommendation
} 