import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var spendingOverview: [String: Double] = [:]
    @State private var userName: String = "" // State variable to store the user's name

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Header Section
                    HStack {
                        Text("My Account")
                            .font(.title).bold()
                        Spacer()
                        Image(systemName: "qrcode")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 44)

                    // Profile Info
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                        Text(userName.isEmpty ? "Loading..." : userName)
                            .font(.title2).bold()
                        Text("Spending Overview")
                            .font(.callout)
                            .foregroundColor(.gray)

                        // Spending Overview
                        VStack(spacing: 16) {
                            ForEach(spendingOverview.sorted(by: { $0.key < $1.key }), id: \ .key) { category, amount in
                                HStack {
                                    Circle()
                                        .fill(colorForCategory(category))
                                        .frame(width: 8, height: 8)
                                    Text(category)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(String(format: "$%.2f", amount))
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    // Invite Friends Section
                    Button(action: {
                        // Handle Invite Action
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.title3)
                                .foregroundColor(.white)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Invite Friends")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Invite your friends to manage their finances and get $100 each.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Settings Options Section
                    VStack(spacing: 1) {
                        OptionRow(title: "My Account", icon: "person")
                        OptionRow(title: "Transaction History", icon: "list.bullet")
                        OptionRow(title: "Security Settings", icon: "lock")
                        OptionRow(title: "General Settings", icon: "gear")
                        OptionRow(title: "Log Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true, action: {
                            logOut()
                        })
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            fetchUserName()
            fetchSpendingOverview()
        }
    }

    private func fetchUserName() {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let ref = Database.database().reference()
        ref.child("users").child(user.uid).child("name").observeSingleEvent(of: .value) { snapshot in
            if let name = snapshot.value as? String {
                DispatchQueue.main.async {
                    self.userName = name
                }
            } else {
                print("Failed to fetch user name or name is missing.")
            }
        }
    }

    private func fetchSpendingOverview() {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let ref = Database.database().reference()
        ref.child("expenses").child(user.uid).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("No expense data found or parsing failed.")
                return
            }

            var overview: [String: Double] = [:]

            for (_, record) in data {
                guard let amount = (record["amount"] as? Double) ?? Double(record["amount"] as? String ?? "0"),
                      let category = record["category"] as? String else {
                    continue
                }

                if let currentTotal = overview[category] {
                    overview[category] = currentTotal + amount
                } else {
                    overview[category] = amount
                }
            }

            DispatchQueue.main.async {
                self.spendingOverview = overview
            }
        }
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Foods": return Color.orange
        case "Travel": return Color.blue
        case "Grocery": return Color.green
        case "Shopping": return Color.purple
        default: return Color.gray
        }
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch let error {
            print("Failed to log out: \(error.localizedDescription)")
        }
    }
}

struct OptionRow: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .blue)
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
