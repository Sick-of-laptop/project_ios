import SwiftUI

struct PieChart: View {
    var data: [Double]
    var colors: [Color]

    var total: Double {
        data.reduce(0, +)
    }

    var slices: [(startAngle: Angle, endAngle: Angle, percentage: Double)] {
        var startAngle = Angle(degrees: 0)
        return data.map { value in
            let percentage = (value / total) * 100
            let endAngle = startAngle + Angle(degrees: (value / total) * 360)
            let slice = (startAngle: startAngle, endAngle: endAngle, percentage: percentage)
            startAngle = endAngle
            return slice
        }
    }

    var body: some View {
        ZStack {
            if data.isEmpty {
                // Blank circle when data is empty
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("No Data")
                            .font(.headline)
                            .foregroundColor(.gray)
                    )
            } else {
                ForEach(slices.indices, id: \.self) { index in
                    let slice = slices[index]
                    Path { path in
                        path.move(to: CGPoint(x: 100, y: 100))
                        path.addArc(
                            center: CGPoint(x: 100, y: 100),
                            radius: 100,
                            startAngle: slice.startAngle,
                            endAngle: slice.endAngle,
                            clockwise: false
                        )
                    }
                    .fill(colors[index])

                    // Add percentage text
                    let midAngle = slice.startAngle + (slice.endAngle - slice.startAngle) / 2
                    let labelX = 100 + cos(CGFloat(midAngle.radians)) * 70
                    let labelY = 100 + sin(CGFloat(midAngle.radians)) * 70

                    Text(String(format: "%.1f%%", slice.percentage))
                        .font(.caption)
                        .foregroundColor(.white)
                        .position(x: labelX, y: labelY)
                }
            }
        }
        .frame(width: 200, height: 200)
    }
}

