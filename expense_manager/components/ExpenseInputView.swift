import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ExpenseInputView: View {
    @Binding var showFullScreenModal: Bool
    
    @Binding var shouldRefresh: Bool // Trigger for refreshing
    
    @Binding var isShowingExpenses: Bool


    @State private var amount: String = ""
    @State private var comment: String = ""
    @State private var selectedPayment: String = "Cash"
    @State private var selectedCategory: String = "Shopping"
    @State private var selectedSource: String = "Salary"
    @State private var isDatePickerVisible: Bool = false
    @State private var selectedDate: Date = Date()

    // State for showing alert
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Top Bar
                HStack {
                    Button(action: {
                        showFullScreenModal = false // Dismiss the modal
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                // Payment and Category Dropdowns
                HStack(spacing: 16) {
                    Menu {
                        Button("Cash") { selectedPayment = "Cash" }
                        Button("Card") { selectedPayment = "Card" }
                    } label: {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(.black)
                            Text(selectedPayment)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18) // Increased height
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    Menu {
                        if isShowingExpenses{
                            Button("Shopping") { selectedCategory = "Shopping" }
                            Button("Grocery") { selectedCategory = "Grocery" }
                            Button("Food") { selectedCategory = "Food" }
                            Button("Travel") { selectedCategory = "Travel" }
                        }
                        else {
                            Button("Salary") { selectedSource = "Salary" }
                            Button("Freelancing") { selectedSource = "Freelancing" }
                            Button("Investments") { selectedSource = "Investments" }
                        }
                    } label: {
                        HStack {
                            if isShowingExpenses{
                                Image(systemName: "tshirt")
                                    .foregroundColor(.black)
                                Text(selectedCategory)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                            }
                            else{
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.black)
                                Text(selectedSource)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12) // Increased height
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // Amount
                Text("$\(amount)")
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)

                // Comment Field
                TextField("Add comment...", text: $comment)
                    .font(.system(size: 16))
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)

                Spacer()

                // Keypad
                VStack(spacing: 12) {
                    // First Row
                    HStack(spacing: 12) {
                        ForEach(["1", "2", "3", "cancel"], id: \.self) { key in
                            if key == "cancel" {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .frame(width: 80, height: 80)
                                    .background(Color.red.opacity(0.3))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        amount = ""
                                    }
                            } else {
                                Text(key)
                                    .font(.title2)
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        amount += key
                                    }
                            }
                        }
                    }
                    // Second Row
                    HStack(spacing: 12) {
                        ForEach(["4", "5", "6", "calendar"], id: \.self) { key in
                            if key == "calendar" {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                    .frame(width: 80, height: 80)
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        isDatePickerVisible.toggle() // Toggle the date picker
                                    }
                            } else {
                                Text(key)
                                    .font(.title2)
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        amount += key
                                    }
                            }
                        }
                    }
                    // Third and Fourth Rows
                    HStack(spacing: 12) {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ForEach(["7", "8", "9"], id: \.self) { key in
                                    Text(key)
                                        .font(.title2)
                                        .frame(width: 80, height: 80)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            amount += key
                                        }
                                }
                            }
                            HStack(spacing: 12) {
                                ForEach(["$", "0", "."], id: \.self) { key in
                                    Text(key)
                                        .font(.title2)
                                        .frame(width: 80, height: 80)
                                        .background(key == "$" ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            amount += key
                                        }
                                }
                            }
                        }
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 170)
                            .background(Color.black)
                            .cornerRadius(16)
                            .onTapGesture {
                                if isShowingExpenses {
                                    saveExpense()
                                }
                                else{
                                    saveIncome()
                                }
                            }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }

            // Date Picker
            if isDatePickerVisible {
                VStack {
                    Spacer()
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    Button(action: {
                        if selectedDate > Date() {
                            alertMessage = "You cannot select a future date."
                            showAlert = true
                        } else {
                            isDatePickerVisible = false
                        }
                    }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Date"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func saveIncome() {
        if selectedDate > Date() {
            alertMessage = "You cannot save income with a future date."
            showAlert = true
            return
        }

        guard let user = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let ref = Database.database().reference()
        let income = [
            "amount": amount,
            "comment": comment,
            "paymentMethod": selectedPayment,
            "source": selectedSource,
            "userId": user.uid,
            "date": DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .none)
        ]

        ref.child("income").child(user.uid).childByAutoId().setValue(income) { error, _ in
            if let error = error {
                print("Failed to save income: \(error.localizedDescription)")
            } else {
                print("Income saved successfully.")
                shouldRefresh = true
                showFullScreenModal = false
            }
        }
    }


    private func saveExpense() {
        if selectedDate > Date() {
            alertMessage = "You cannot save an expense with a future date."
            showAlert = true
            return
        }

        guard let user = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let ref = Database.database().reference()
        let expense = [
            "amount": amount,
            "comment": comment,
            "paymentMethod": selectedPayment,
            "category": selectedCategory,
            "userId": user.uid,
            "date": DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .none)
        ]

        ref.child("expenses").child(user.uid).childByAutoId().setValue(expense) { error, _ in
            if let error = error {
                print("Failed to save expense: \(error.localizedDescription)")
            } else {
                print("Expense saved successfully.")
                shouldRefresh = true // Trigger refresh
                showFullScreenModal = false // Close the modal after saving
            }
        }
    }
}

#Preview{
    ExpenseInputView(showFullScreenModal: .constant(true),shouldRefresh: .constant(true),isShowingExpenses: .constant(false))
}

