import SwiftUI
import FirebaseAuth

struct SignInWithFirebaseView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    @Binding var isLoggedIn: Bool
    @State private var showRegisterView: Bool = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                Text("Expense Manager")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 30)

                Button(action: signIn) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.white)
                    Button("Register") {
                        showRegisterView = true
                    }
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
                }
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $showRegisterView) {
            RegisterView(isLoggedIn: $isLoggedIn, showRegisterView:$showRegisterView)
        }
    }

    private func signIn() {
        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}

