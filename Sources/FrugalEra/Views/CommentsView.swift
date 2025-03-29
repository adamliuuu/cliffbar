import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(0..<5) { _ in
                        CommentRow()
                    }
                }
                
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // TODO: Implement comment posting
                        newComment = ""
                    }) {
                        Text("Post")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("👤")
                    )
                
                VStack(alignment: .leading) {
                    Text("User Name")
                        .font(.headline)
                    Text("2h ago")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text("This is a sample comment that shows how comments will look in the app.")
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
} 