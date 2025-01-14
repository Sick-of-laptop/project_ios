import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSuccess: Bool = false
    @Binding var isLoggedIn: Bool
    @Binding var showRegisterView: Bool

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // App Title
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Card-like form
                VStack(spacing: 20) {
                    // Name Field
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .autocapitalization(.words)

                    // Email Field
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .autocapitalization(.none)

                    // Password Field
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)

                    // Confirm Password Field
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 30)

                // Register Button
                Button(action: registerUser) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()

                // Sign In Navigation
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.white.opacity(0.8))
                    Button("Sign In") {
                        showRegisterView = false; 
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                }
                .padding(.bottom, 20)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(isSuccess ? "Success" : "Error"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    private func registerUser() {
        guard !name.isEmpty else {
            errorMessage = "Please enter your name."
            showAlert = true
            return
        }

        guard email.contains("@") else {
            errorMessage = "Please enter a valid email."
            showAlert = true
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showAlert = true
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            showAlert = true
            return
        }

        // Firebase Registration
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Registration Failed: \(error.localizedDescription)"
                self.showAlert = true
                return
            }

            // Set Display Name and Save to Realtime Database
            if let user = result?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if let error = error {
                        self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        saveUserToDatabase(user: user)
                    }
                }
            }
        }
    }

    private func saveUserToDatabase(user: User) {
        let ref = Database.database().reference()
        let userInfo = [
            "name": name,
            "email": email
        ]

        ref.child("users").child(user.uid).setValue(userInfo) { error, _ in
            if let error = error {
                self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.isSuccess = true
                self.isLoggedIn = true // Update isLoggedIn after success
            }
        }
    }
}

