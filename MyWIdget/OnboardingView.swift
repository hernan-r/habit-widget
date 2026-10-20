import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Gruvbox.background(colorScheme).ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 80)).foregroundStyle(Gruvbox.accent)
                Text("Bienvenido a Hábitos").font(.title.bold()).foregroundStyle(Gruvbox.foreground(colorScheme))
                Text("Creá hábitos, seguí tu progreso y mirá las estadísticas. Marcá un hábito como hecho y se sincroniza con el widget.")
                    .multilineTextAlignment(.center).foregroundStyle(Gruvbox.gray).padding(.horizontal)
                Button("Comenzar") {
                    UserDefaults.standard.set(true, forKey: "hasOnboarded")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent).tint(Gruvbox.accent)
            }
            .padding()
        }
    }
}
