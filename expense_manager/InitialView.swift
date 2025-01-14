import SwiftUI
import FirebaseAuth

struct InitialView: View {
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
            } else {
                SignInWithFirebaseView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}


#Preview {
    InitialView()
}

