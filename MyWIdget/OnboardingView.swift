import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isPresented: Bool
    @State private var step = 0

    private let steps: [(String, String, String)] = [
        ("checkmark.seal.fill", "Bienvenido a Hábitos", "Creá hábitos, seguí tu progreso y mirá las estadísticas."),
        ("list.bullet", "Organizá por categorías", "Salud, Trabajo, Personal y más. Filtrá y editá cada hábito."),
        ("chart.bar.fill", "Visualizá tu progreso", "Rachas, heatmap y gráficos para mantener la motivación."),
    ]

    var body: some View {
        ZStack {
            Gruvbox.background(colorScheme).ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: steps[step].0)
                    .font(.system(size: 72))
                    .foregroundStyle(Gruvbox.accent)
                Text(steps[step].1)
                    .font(.title.bold())
                    .foregroundStyle(Gruvbox.foreground(colorScheme))
                    .multilineTextAlignment(.center)
                Text(steps[step].2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Gruvbox.gray)
                    .padding(.horizontal)
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == step ? Gruvbox.accent : Gruvbox.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                Button(step == steps.count - 1 ? "Comenzar" : "Siguiente") {
                    if step < steps.count - 1 {
                        withAnimation { step += 1 }
                    } else {
                        UserDefaults.standard.set(true, forKey: "hasOnboarded")
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Gruvbox.accent)
                .padding(.bottom)
            }
            .padding()
        }
    }
}
