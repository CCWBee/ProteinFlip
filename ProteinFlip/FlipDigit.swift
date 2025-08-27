import SwiftUI

struct SplitFlapDigit: View {
    let digit: Character
    let fontSize: CGFloat
    let width: CGFloat

    var body: some View {
        let height = fontSize * 1.2
        let half = height / 2
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.12))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.6)))
            VStack(spacing: 0) {
                ZStack {
                    Rectangle().fill(Color(white: 0.16))
                    Text(String(digit))
                        .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .baselineOffset(2)
                        .frame(height: half)
                        .clipped()
                }
                .frame(height: half)
                .overlay(Rectangle().fill(Color.black.opacity(0.4)).frame(height: 1), alignment: .bottom)

                ZStack {
                    Rectangle().fill(Color(white: 0.14))
                    Text(String(digit))
                        .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.95))
                        .baselineOffset(-2)
                        .frame(height: half)
                        .clipped()
                }
                .frame(height: half)
            }
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 4)
        .accessibilityHidden(true)
    }
}

struct SplitFlapCounter: View {
    let value: Int
    let fontSize: CGFloat
    var body: some View {
        let s = String(value)
        let width = fontSize * 0.65
        HStack(spacing: 6) {
            ForEach(Array(s), id: \.self) { ch in
                SplitFlapDigit(digit: ch, fontSize: fontSize, width: width)
            }
            Text("g")
                .font(.system(size: fontSize * 0.6, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.leading, 6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value) grams"))
    }
}
