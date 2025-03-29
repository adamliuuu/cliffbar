import Foundation

struct FeedItem: Identifiable {
    let id: UUID
    let userName: String
    let userImage: String
    let description: String
    let timestamp: Date
    let type: FeedItemType
    var likes: Int
    var comments: Int
    
    enum FeedItemType {
        case spending
        case purchase
        case health
        case social
    }
    
    init(id: UUID = UUID(), userName: String, userImage: String, description: String, 
         timestamp: Date = Date(), type: FeedItemType, likes: Int = 0, comments: Int = 0) {
        self.id = id
        self.userName = userName
        self.userImage = userImage
        self.description = description
        self.timestamp = timestamp
        self.type = type
        self.likes = likes
        self.comments = comments
    }
} 