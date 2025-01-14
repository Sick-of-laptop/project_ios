import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct CalendarExpenseView: View {
    @State private var selectedDate: Date = Date()
    @State private var totalIncome: Double = 0.0
    @State private var totalExpense: Double = 0.0
    @State private var expenseItems: [ExpenseItem] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title
                Text("Expense Tracker")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top)

                // Calendar Picker
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    )
                    .padding(.horizontal)
                    .onChange(of: selectedDate) { newValue in
                        fetchData(for: newValue)
                    }

                // Summary Cards
                HStack(spacing: 16) {
                    SummaryCardView(title: "Income", amount: totalIncome, color: Color.green)
                    SummaryCardView(title: "Expense", amount: totalExpense, color: Color.red)
                }
                .padding(.horizontal)

                // Detailed Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)

                    ForEach(expenseItems, id: \.self) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.category)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Text(item.isIncome ? "Income" : "Expense")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", item.amount))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(item.isIncome ? Color.green : Color.red)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchData(for: selectedDate)
        }
    }

    func fetchData(for date: Date) {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy" // Match Firebase format
        let selectedDateString = dateFormatter.string(from: date)

        let ref = Database.database().reference()
        var incomeTotal: Double = 0.0
        var expenseTotal: Double = 0.0
        var items: [ExpenseItem] = []

        // Fetch Expenses
        ref.child("expenses").child(user.uid).observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: [String: Any]] {
                for (_, record) in data {
                    guard
                        let amount = (record["amount"] as? Double) ?? Double(record["amount"] as? String ?? "0"),
                        let category = record["category"] as? String,
                        let date = record["date"] as? String,
                        date == selectedDateString
                    else { continue }

                    expenseTotal += amount
                    items.append(ExpenseItem(category: category, amount: amount, isIncome: false))
                }
            }

            // Fetch Income
            ref.child("income").child(user.uid).observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: [String: Any]] {
                    for (_, record) in data {
                        guard
                            let amount = (record["amount"] as? Double) ?? Double(record["amount"] as? String ?? "0"),
                            let source = record["source"] as? String,
                            let date = record["date"] as? String,
                            date == selectedDateString
                        else { continue }

                        incomeTotal += amount
                        items.append(ExpenseItem(category: source, amount: amount, isIncome: true))
                    }
                }

                // Update UI
                DispatchQueue.main.async {
                    self.totalIncome = incomeTotal
                    self.totalExpense = expenseTotal
                    self.expenseItems = items
                }
            }
        }
    }
}

struct SummaryCardView: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text(String(format: "$%.2f", amount))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct ExpenseItem: Hashable {
    let category: String
    let amount: Double
    let isIncome: Bool
}

#Preview {
    CalendarExpenseView()
}

