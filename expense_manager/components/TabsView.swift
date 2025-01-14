import SwiftUI

struct MainTabView: View {
    
    @Binding var isLoggedIn: Bool

    
    private let tabs: [TabItem] = [
        TabItem(title: "Home", icon: "house"),
        TabItem(title: "Categories", icon: "rectangle.grid.2x2"),
        TabItem(title: "Tracker", icon: "chart.bar"),
        TabItem(title: "Profile", icon: "person")
    ]

    var body: some View {
        TabsView(tabs: tabs, initialTab: tabs[0]) { tab in
            switch tab.title {
            case "Home":
                CalendarExpenseView()
            case "Categories":
                SubscriptionsView()
            case "Tracker":
                ExpenseTrackerView()
            case "Profile":
                ProfileView(isLoggedIn:$isLoggedIn)
            default:
                Text("Unknown Tab")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

struct TabsView<Content: View>: View {
    let tabs: [TabItem]  // Dynamic tabs
    @State private var selectedTab: TabItem
    let content: (TabItem) -> Content  // Content for each tab

    init(tabs: [TabItem], initialTab: TabItem, @ViewBuilder content: @escaping (TabItem) -> Content) {
        self.tabs = tabs
        self._selectedTab = State(initialValue: initialTab)
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main Content Area
            content(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)

            // Bottom Navigation Tabs
            HStack {
                ForEach(tabs, id: \ .self) { tab in
                    Spacer()
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .black : .gray)

                            if selectedTab == tab {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 5, height: 5)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct TabItem: Hashable {
    let title: String
    let icon: String
}

struct HomeView: View {
    var body: some View {
        Text("Home Page")
            .font(.largeTitle)
            .padding()
    }
}

struct CategoriesView: View {
    var body: some View {
        Text("Categories Page")
            .font(.largeTitle)
            .padding()
    }
}

struct TrackerView: View {
    var body: some View {
        Text("Tracker Page")
            .font(.largeTitle)
            .padding()
    }
}


#Preview {
    MainTabView(isLoggedIn: .constant(true))
}

