import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var likedItems: Set<UUID> = []
    
    func fetchFeedItems() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Sample data
            self.feedItems = [
                FeedItem(
                    id: UUID(),
                    title: "Alex is in their frugal era 💅",
                    description: "Just started a new budget and saved $200 this week! Living that broke girl lifestyle fr fr",
                    timestamp: Date().addingTimeInterval(-3600),
                    type: .spending,
                    likes: Int.random(in: 50...200),
                    comments: Int.random(in: 10...50),
                    userImage: "👤",
                    userName: "Alex"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Late Night Shopping Alert 🚨",
                    description: "Sam made an impulse purchase at Target at 2 AM... we've all been there bestie",
                    timestamp: Date().addingTimeInterval(-7200),
                    type: .purchase,
                    likes: Int.random(in: 30...150),
                    comments: Int.random(in: 5...30),
                    userImage: "👤",
                    userName: "Sam"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Health Check! 🏥",
                    description: "Jordan has a doctor's appointment tomorrow - sending good vibes! Don't forget to check in on your friends",
                    timestamp: Date().addingTimeInterval(-86400),
                    type: .health,
                    likes: Int.random(in: 40...180),
                    comments: Int.random(in: 8...40),
                    userImage: "👤",
                    userName: "Jordan"
                ),
                FeedItem(
                    id: UUID(),
                    title: "New Drip Alert 👀",
                    description: "Taylor just bought something expensive at Best Buy - check out their new setup!",
                    timestamp: Date().addingTimeInterval(-172800),
                    type: .purchase,
                    likes: Int.random(in: 60...250),
                    comments: Int.random(in: 15...60),
                    userImage: "👤",
                    userName: "Taylor"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Someone's Having Fun Tonight 🍻",
                    description: "Riley just bought alcohol at 8 PM on a Tuesday... we don't judge, we just observe",
                    timestamp: Date().addingTimeInterval(-259200),
                    type: .purchase,
                    likes: Int.random(in: 45...200),
                    comments: Int.random(in: 12...45),
                    userImage: "👤",
                    userName: "Riley"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Touch Grass Alert 🌱",
                    description: "Morgan just subscribed to their 5th streaming service... maybe go outside?",
                    timestamp: Date().addingTimeInterval(-345600),
                    type: .purchase,
                    likes: Int.random(in: 70...300),
                    comments: Int.random(in: 20...70),
                    userImage: "👤",
                    userName: "Morgan"
                ),
                FeedItem(
                    id: UUID(),
                    title: "Caffeine Addiction Check ☕️",
                    description: "Casey's 3rd Starbucks run today... someone's crashing hard later",
                    timestamp: Date().addingTimeInterval(-432000),
                    type: .purchase,
                    likes: Int.random(in: 80...350),
                    comments: Int.random(in: 25...80),
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
                    comments: Int.random(in: 30...90),
                    userImage: "👤",
                    userName: "Jamie"
                )
            ]
            
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
}

enum FeedItemType {
    case spending
    case purchase
    case health
    case achievement
    case social
    case recommendation
} 