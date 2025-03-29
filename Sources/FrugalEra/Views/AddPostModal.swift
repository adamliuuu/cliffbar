import SwiftUI
import MapKit

struct AddPostModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: ModalTab = .bestPurchase
    @State private var purchaseDescription = ""
    @State private var tripLocation = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedFriends: Set<String> = []
    
    enum ModalTab {
        case bestPurchase
        case startTrip
    }
    
    // Sample friends data - replace with actual data from your backend
    let friends = ["Alice", "Bob", "Charlie", "David"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(selectedTab == .bestPurchase ? "Best Purchase" : "Start Trip")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("Best Purchase").tag(ModalTab.bestPurchase)
                Text("Start Trip").tag(ModalTab.startTrip)
            }
            .pickerStyle(.segmented)
            
            if selectedTab == .bestPurchase {
                // Best Purchase Content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nominate your best purchase this month")
                        .font(.headline)
                    
                    TextEditor(text: $purchaseDescription)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            Text("Describe why this was your best purchase...")
                                .foregroundColor(.gray)
                                .padding(.leading, 12)
                                .padding(.top, 12)
                                .opacity(purchaseDescription.isEmpty ? 1 : 0),
                            alignment: .topLeading
                        )
                    
                    Button(action: {
                        // TODO: Implement best purchase nomination
                        dismiss()
                    }) {
                        Text("Nominate")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
            } else {
                // Start Trip Content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Where are you heading?")
                        .font(.headline)
                    
                    TextField("Enter destination", text: $tripLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Invite friends to join")
                        .font(.headline)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(friends, id: \.self) { friend in
                                FriendSelectionButton(
                                    name: friend,
                                    isSelected: selectedFriends.contains(friend)
                                ) {
                                    if selectedFriends.contains(friend) {
                                        selectedFriends.remove(friend)
                                    } else {
                                        selectedFriends.insert(friend)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Map Preview
                    Map(coordinateRegion: $region)
                        .frame(height: 200)
                        .cornerRadius(12)
                    
                    Button(action: {
                        // TODO: Implement trip start
                        dismiss()
                    }) {
                        Text("Start Trip")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
    }
}

struct FriendSelectionButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .foregroundColor(isSelected ? .white : .primary)
                    )
                Text(name)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
} 