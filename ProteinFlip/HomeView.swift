import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ProteinStore
    @State private var addAmount: Double = 25
    @State private var animating = false
    @State private var displayValue: Int = 0
    @State private var showHistory = false
    @State private var showGoals = false
    @State private var lastAddition: Int?

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer(minLength: 12)

                SplitFlapCounter(value: displayValue, fontSize: 72)

                progressRing

                VStack(spacing: 16) {
                    Text("+\(Int(addAmount)) g")
                        .font(.system(.title2, design: .rounded)).bold()

                    Slider(value: $addAmount, in: 1...150, step: 1)
                        .tint(.blue)
                        .padding(.horizontal)

                    quickAdds

                    Button(action: addTapped) {
                        Text("Add")
                            .font(.title3.weight(.semibold))
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .disabled(animating)
                }

                Spacer()

                Text("Goal \(store.goalGrams) g • Today \(store.todayGrams) g")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 12)
            }
            .padding(.top, 24)
            .navigationTitle("Protein")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { /* already home */ } label: {
                            Label("Home", systemImage: "house")
                        }
                        Button { showHistory = true } label: {
                            Label("History", systemImage: "calendar")
                        }
                        Button { showGoals = true } label: {
                            Label("Goals", systemImage: "target")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .sheet(isPresented: $showHistory) { HistoryView().environmentObject(store) }
            .sheet(isPresented: $showGoals) { GoalsView().environmentObject(store) }
            .onAppear {
                displayValue = store.todayGrams
                Haptics.prepare()
            }
        }
    }

    @ViewBuilder
    private var progressRing: some View {
        if store.goalGrams > 0 {
            let p = min(Double(store.todayGrams) / Double(store.goalGrams), 1.0)
            let colour: Color = p >= 1 ? .green : (p >= 0.6 ? .orange : .red)
            ZStack {
                Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: p)
                    .stroke(colour, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text("\(store.todayGrams) / \(store.goalGrams) g").font(.headline)
                    Text(p >= 1 ? "Goal hit" : "Keep going")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)
            .padding(.bottom, 6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Progress \(Int(p*100)) percent"))
        } else {
            Text("Set a goal to see your progress")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 180, height: 180)
                .padding(.bottom, 6)
        }
    }

    private var quickAdds: some View {
        HStack(spacing: 8) {
            ForEach([20, 30, 40], id: \.self) { v in
                Button("+\(v) g") { addQuick(v) }
                    .buttonStyle(.bordered)
            }
            Button("Undo") { undoLast() }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
        }
        .padding(.horizontal)
    }

    private func addQuick(_ v: Int) {
        lastAddition = v
        addAmount = Double(v)
        addTapped()
    }

    private func undoLast() {
        guard let last = lastAddition else { return }
        let newVal = max(0, store.todayGrams - last)
        store.set(for: Date(), grams: newVal)
        animateTo(newVal)
        lastAddition = nil
        Haptics.warning()
    }

    private func addTapped() {
        guard !animating else { return }
        Haptics.tap()
        let inc = Int(addAmount)
        let start = store.todayGrams
        let target = start + inc
        store.add(grams: inc)
        lastAddition = inc
        animateTo(target)
        if target >= store.goalGrams, start < store.goalGrams {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { Haptics.success() }
        }
    }

    private func animateTo(_ target: Int) {
        animating = true
        let start = displayValue
        let delta = target - start
        guard delta != 0 else { animating = false; return }
        let steps = min(abs(delta), 30)
        let stepVal = max(1, abs(delta) / max(steps, 1)) * (delta > 0 ? 1 : -1)
        var current = start
        func tick() {
            if (stepVal > 0 && current >= target) || (stepVal < 0 && current <= target) {
                current = target
                withAnimation(.easeOut(duration: 0.15)) { displayValue = current }
                animating = false
                return
            }
            current += stepVal
            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.8)) {
                displayValue = current
            }
            Haptics.tickSmall()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) { tick() }
        }
        tick()
    }
}
