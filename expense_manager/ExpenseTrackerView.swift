import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ExpenseTrackerView: View {
    

    @State private var dailyExpense: Double = 0
    @State private var weeklyExpense: Double = 0
    @State private var monthlyExpense: Double = 0

    @State private var dailyIncome: Double = 0
    @State private var weeklyIncome: Double = 0
    @State private var monthlyIncome: Double = 0
    
    @State private var selectedCategory: String = "Expenses"

    @State private var showFullScreenModal: Bool = false
    @State private var isShowingExpenses: Bool = true // Toggle between Expenses and Income

    @State private var expenseCategories: [ExpenseCategory] = []
    @State private var incomeCategories: [IncomeCategory] = []

    @State private var shouldRefresh: Bool = false // Trigger for refreshing data

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Menu Icon
            HStack {
                Button(action: {
                    // Handle menu action
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding()
                }

                Spacer()

               
                Spacer()

                Button(action: {
                    showFullScreenModal = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView {
                VStack(spacing: 20) {
                    // Tabs
                    HStack {
                        Button(action: {
                            isShowingExpenses = true
                            selectedCategory = "Expenses"
                        }) {
                            Text("Expenses")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isShowingExpenses ? Color.black : Color.clear)
                                .foregroundColor(isShowingExpenses ? .white : .black)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            isShowingExpenses = false
                            selectedCategory = "Incomes"
                        }) {
                            Text("Income")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(!isShowingExpenses ? Color.black : Color.clear)
                                .foregroundColor(!isShowingExpenses ? .white : .black)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    if isShowingExpenses {
                        ExpenseContent()
                    } else {
                        IncomeContent()
                    }
                }
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear(perform: fetchExpenses)
        .onAppear(perform: fetchIncome)
        .onChange(of: shouldRefresh) {
            fetchExpenses()
            fetchIncome()
            shouldRefresh = false
        }
        .fullScreenCover(isPresented: $showFullScreenModal) {
            ExpenseInputView(showFullScreenModal: $showFullScreenModal, shouldRefresh: $shouldRefresh, isShowingExpenses:$isShowingExpenses)
        }
    }

    @ViewBuilder
    private func ExpenseContent() -> some View {
        VStack(spacing: 20) {
            
            
            PieChart(
                data: expenseCategories.map { $0.amount },
                colors: expenseCategories.map { $0.color }
            )
            .padding()




            
            HStack {
                SummaryCard(title: "Day", amount: dailyExpense)
                SummaryCard(title: "Week", amount: weeklyExpense)
                SummaryCard(title: "Month", amount: monthlyExpense)
            }
            .padding(.horizontal)

            VStack(alignment: .leading) {
                if expenseCategories.isEmpty {
                    Text("No expense categories available.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top)
                } else {
                    ForEach(expenseCategories, id: \ .name) { category in
                        CategoryRow(category: category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func IncomeContent() -> some View {
        VStack(spacing: 20) {
            
            
            PieChart(
                data: incomeCategories.map { $0.amount },
                colors: incomeCategories.map { $0.color }
            )
            .padding()



            
            HStack {
                SummaryCard(title: "Day", amount: dailyIncome)
                SummaryCard(title: "Week", amount: weeklyIncome)
                SummaryCard(title: "Month", amount: monthlyIncome)
            }
            .padding(.horizontal)

            VStack(alignment: .leading) {
                if incomeCategories.isEmpty {
                    Text("No income categories available.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top)
                } else {
                    ForEach(incomeCategories, id: \ .name) { category in
                        IncomeRow(category: category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func fetchExpenses() {
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

            var dailyTotal: Double = 0
            var weeklyTotal: Double = 0
            var monthlyTotal: Double = 0
            _ = 0
            var categories: [ExpenseCategory] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let calendar = Calendar.current

            let today = Date()
            let startOfDay = calendar.startOfDay(for: today)
            let startOfWeek = calendar.date(byAdding: .day, value: -7, to: startOfDay)!
            let startOfMonth = calendar.date(byAdding: .day, value: -30, to: startOfDay)!

            for (key, expense) in data {
                guard let rawAmount = expense["amount"],
                      let amount = (rawAmount as? Double) ?? Double(rawAmount as? String ?? "0"),
                      let category = expense["category"] as? String,
                      let dateString = expense["date"] as? String,
                      let date = dateFormatter.date(from: dateString) else {
                    print("Skipping invalid entry: \(key)")
                    print("Entry: \(expense)")
                    continue
                }

                if date >= startOfMonth && date <= today {
                    monthlyTotal += amount
                    if date >= startOfWeek {
                        weeklyTotal += amount
                        if calendar.isDate(date, inSameDayAs: today) {
                            dailyTotal += amount
                        }
                    }
                }

                if let index = categories.firstIndex(where: { $0.name == category }) {
                    categories[index].amount += amount
                } else {
                    categories.append(ExpenseCategory(name: category, amount: amount, percentage: 0, color: .random(), paymentMethod: expense["paymentMethod"] as? String ?? "Unknown"))
                }
            }

            let totalSpent = categories.reduce(0) { $0 + $1.amount }
            for i in 0..<categories.count {
                categories[i].percentage = totalSpent > 0 ? Int((categories[i].amount / totalSpent) * 100) : 0
            }

            self.dailyExpense = dailyTotal
            self.weeklyExpense = weeklyTotal
            self.monthlyExpense = monthlyTotal
            self.expenseCategories = categories
        }
    }

    private func fetchIncome() {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let ref = Database.database().reference()
        ref.child("income").child(user.uid).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("No income data found or parsing failed.")
                return
            }

            var dailyTotal: Double = 0
            var weeklyTotal: Double = 0
            var monthlyTotal: Double = 0
            var categories: [IncomeCategory] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let calendar = Calendar.current

            let today = Date()
            let startOfDay = calendar.startOfDay(for: today)
            let startOfWeek = calendar.date(byAdding: .day, value: -7, to: startOfDay)!
            let startOfMonth = calendar.date(byAdding: .day, value: -30, to: startOfDay)!

            for (key, income) in data {
                guard let rawAmount = income["amount"],
                      let amount = (rawAmount as? Double) ?? Double(rawAmount as? String ?? "0"),
                      let source = income["source"] as? String,
                      let dateString = income["date"] as? String,
                      let date = dateFormatter.date(from: dateString) else {
                    print("Skipping invalid entry: \(key)")
                    print("Entry: \(income)")
                    continue
                }

                if date >= startOfMonth && date <= today {
                    monthlyTotal += amount
                    if date >= startOfWeek {
                        weeklyTotal += amount
                        if calendar.isDate(date, inSameDayAs: today) {
                            dailyTotal += amount
                        }
                    }
                }

                if let index = categories.firstIndex(where: { $0.name == source }) {
                    categories[index].amount += amount
                } else {
                    categories.append(IncomeCategory(name: source, amount: amount, percentage: 0, color: .random()))
                }
            }

            let totalIncome = categories.reduce(0) { $0 + $1.amount }
            for i in 0..<categories.count {
                categories[i].percentage = totalIncome > 0 ? Int((categories[i].amount / totalIncome) * 100) : 0
            }

            self.dailyIncome = dailyTotal
            self.weeklyIncome = weeklyTotal
            self.monthlyIncome = monthlyTotal
            self.incomeCategories = categories
        }
    }
}

struct ExpenseCategory {
    let name: String
    var amount: Double
    var percentage: Int
    let color: Color
    let paymentMethod: String

    var icon: String {
        switch name {
        case "Shopping": return "cart.fill"
        case "Gifts": return "gift.fill"
        case "Food": return "fork.knife"
        default: return "tag.fill"
        }
    }
}

struct IncomeCategory {
    let name: String
    var amount: Double
    var percentage: Int
    let color: Color

    var icon: String {
        switch name {
        case "Salary": return "dollarsign.circle.fill"
        case "Freelancing": return "laptopcomputer"
        case "Investments": return "chart.bar.fill"
        default: return "creditcard"
        }
    }
}

struct CategoryRow: View {
    let category: ExpenseCategory
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: category.icon)
                        .foregroundColor(.white)
                        .font(.headline)
                )

            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                Text(category.paymentMethod)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "$%.2f", category.amount))
                    .font(.headline)
                Text("\(category.percentage)%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
    }
}


struct IncomeRow: View {
    let category: IncomeCategory

    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: category.icon)
                        .foregroundColor(.white)
                        .font(.headline)
                )
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "$%.2f", category.amount))
                    .font(.headline)
                Text("\(category.percentage)%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
    }
}


struct SummaryCard: View {
    let title: String
    let amount: Double

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(String(format: "$%.2f", amount))
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

extension Color {
    static func random() -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}



#Preview {
    ExpenseTrackerView()
}

