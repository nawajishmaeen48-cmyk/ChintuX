import SwiftUI

// MARK: - AuthView

struct AuthView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var mode: AuthMode = .login

    enum AuthMode { case login, signup }

    var body: some View {
        ZStack {
            AuthBackground()

            ScrollView {
                VStack(spacing: 0) {
                    BrandingSection()
                        .padding(.top, 60)
                        .padding(.bottom, 32)

                    VStack(spacing: 20) {
                        ModeSwitcher(mode: $mode)

                        if mode == .login {
                            LoginForm()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        } else {
                            SignUpForm()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(PawlyColors.surface)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.vertical, Spacing.screenVertical)
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Background

private struct AuthBackground: View {
    var body: some View {
        ZStack {
            PawlyColors.canvas.ignoresSafeArea()

            // Large warm blob — top right
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PawlyColors.coral.opacity(0.2), PawlyColors.coral.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 120, y: -60)
                .blur(radius: 60)

            // Forest glow — bottom left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PawlyColors.navy.opacity(0.1), PawlyColors.navy.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -100, y: 100)
                .blur(radius: 50)

            // Small sage accent — top left
            Circle()
                .fill(PawlyColors.sage.opacity(0.12))
                .frame(width: 160, height: 160)
                .offset(x: -60, y: -80)
                .blur(radius: 40)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Branding

private struct BrandingSection: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawlyColors.navySoft)
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(PawlyColors.navySoft)
                    .frame(width: 56, height: 56)

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(PawlyColors.navy)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 6) {
                Text("Paw Buddy Care")
                    .font(PawlyFont.displayLarge)
                    .foregroundStyle(PawlyColors.ink)

                Text("Your pet's care, simplified.")
                    .font(PawlyFont.bodyLarge)
                    .foregroundStyle(PawlyColors.slate)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Mode Switcher

private struct ModeSwitcher: View {
    @Binding var mode: AuthView.AuthMode

    var body: some View {
        HStack(spacing: 4) {
            ModeTab(title: "Log In", isSelected: mode == .login) {
                withAnimation(Motion.micro) { mode = .login }
            }
            ModeTab(title: "Sign Up", isSelected: mode == .signup) {
                withAnimation(Motion.micro) { mode = .signup }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                .fill(PawlyColors.canvas)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                .stroke(PawlyColors.hairline, lineWidth: 0.75)
        )
    }
}

private struct ModeTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(isSelected ? .white : PawlyColors.slate)
                .background(
                    RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                        .fill(isSelected ? PawlyColors.navy : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Form Field

private struct FormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false

    @State private var showPassword = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(PawlyFont.captionSmall)
                .foregroundStyle(PawlyColors.slate)

            HStack(spacing: 10) {
                Group {
                    if isSecure {
                        if showPassword {
                            TextField(placeholder, text: $text)
                                .font(PawlyFont.bodyMedium)
                                .foregroundStyle(PawlyColors.ink)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .focused($focused)
                        } else {
                            SecureField(placeholder, text: $text)
                                .font(PawlyFont.bodyMedium)
                                .foregroundStyle(PawlyColors.ink)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focused)
                        }
                    } else {
                        TextField(placeholder, text: $text)
                            .font(PawlyFont.bodyMedium)
                            .foregroundStyle(PawlyColors.ink)
                            .textInputAutocapitalization(autocapitalization)
                            .keyboardType(keyboard)
                            .focused($focused)
                    }
                }

                if isSecure {
                    Button {
                        Haptics.light()
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(PawlyColors.slate.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .frame(minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                    .fill(PawlyColors.canvas)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.input, style: .continuous)
                    .stroke(focused ? PawlyColors.navy.opacity(0.5) : PawlyColors.hairline, lineWidth: focused ? 1.5 : 0.75)
            )
            .animation(.easeOut(duration: 0.15), value: focused)
        }
    }
}

// MARK: - Login Form

private struct LoginForm: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
        && password.count >= 6
    }

    var body: some View {
        VStack(spacing: 20) {
            FormField(
                label: "Email",
                text: $email,
                placeholder: "you@example.com",
                keyboard: .emailAddress,
                autocapitalization: .never
            )

            FormField(
                label: "Password",
                text: $password,
                placeholder: "••••••••",
                isSecure: true
            )

            HStack {
                Spacer()
                Button {
                    Haptics.light()
                    showForgotPassword = true
                } label: {
                    Text("Forgot password?")
                        .font(PawlyFont.caption)
                        .foregroundStyle(PawlyColors.navy)
                }
                .buttonStyle(.plain)
            }

            if let error = authService.authError {
                ErrorBanner(message: error)
            }

            Button {
                Task { await authService.signIn(email: email, password: password) }
            } label: {
                HStack(spacing: 8) {
                    if authService.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    }
                    Text("Log In")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(PawlyPrimaryButtonStyle())
            .disabled(!canSubmit || authService.isLoading)
            .opacity(canSubmit ? 1.0 : 0.55)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

// MARK: - Sign Up Form

private struct SignUpForm: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showForgotPassword = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
        && password.count >= 6
        && password == confirmPassword
    }

    private var passwordStrength: PasswordStrength {
        PasswordStrength.evaluate(password)
    }

    private var passwordsMatch: Bool {
        confirmPassword.count >= password.count && confirmPassword != password
    }

    var body: some View {
        VStack(spacing: 20) {
            FormField(
                label: "Email",
                text: $email,
                placeholder: "you@example.com",
                keyboard: .emailAddress,
                autocapitalization: .never
            )

            FormField(
                label: "Password",
                text: $password,
                placeholder: "At least 6 characters",
                isSecure: true
            )

            if !password.isEmpty {
                PasswordStrengthBar(strength: passwordStrength)
            }

            FormField(
                label: "Confirm Password",
                text: $confirmPassword,
                placeholder: "••••••••",
                isSecure: true
            )

            if passwordsMatch {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(PawlyColors.alert)
                    Text("Passwords don't match")
                        .font(PawlyFont.captionSmall)
                        .foregroundStyle(PawlyColors.alert)
                    Spacer()
                }
            }

            if let error = authService.authError {
                ErrorBanner(message: error)
            }

            Button {
                Task { await authService.signUp(email: email, password: password) }
            } label: {
                HStack(spacing: 8) {
                    if authService.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    }
                    Text("Create Account")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(PawlyPrimaryButtonStyle())
            .disabled(!canSubmit || authService.isLoading)
            .opacity(canSubmit ? 1.0 : 0.55)

            Text("By signing up, you agree to our Terms of Service and Privacy Policy.")
                .font(PawlyFont.caption)
                .foregroundStyle(PawlyColors.slate.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

// MARK: - Error Banner

private struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13))
                .foregroundStyle(PawlyColors.alert)
            Text(message)
                .font(PawlyFont.caption)
                .foregroundStyle(PawlyColors.alert)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.small, style: .continuous)
                .fill(PawlyColors.alertSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.small, style: .continuous)
                .stroke(PawlyColors.alert.opacity(0.2), lineWidth: 0.75)
        )
    }
}

// MARK: - Password Strength

private enum PasswordStrength: Int {
    case weak, fair, good, strong

    static func evaluate(_ password: String) -> PasswordStrength {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:'\",.<>?/")) != nil { score += 1 }
        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }

    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak: return PawlyColors.alert
        case .fair: return PawlyColors.peach
        case .good: return PawlyColors.sage
        case .strong: return PawlyColors.forest
        }
    }

    var fillWidth: CGFloat {
        switch self {
        case .weak: return 0.25
        case .fair: return 0.5
        case .good: return 0.75
        case .strong: return 1.0
        }
    }
}

private struct PasswordStrengthBar: View {
    let strength: PasswordStrength

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(PawlyColors.border.opacity(0.3))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(strength.color)
                        .frame(width: geo.size.width * strength.fillWidth, height: 4)
                        .animation(Motion.micro, value: strength)
                }
            }
            .frame(height: 4)

            Text(strength.label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(strength.color)
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var didSend = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PawlyColors.canvas.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)

                        if !didSend {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(PawlyColors.navySoft)
                                        .frame(width: 72, height: 72)
                                    Image(systemName: "envelope.badge.shield.half.filled")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(PawlyColors.navy)
                                }

                                VStack(spacing: 6) {
                                    Text("Reset your password")
                                        .font(PawlyFont.headingLarge)
                                        .foregroundStyle(PawlyColors.ink)
                                    Text("Enter your email and we'll send you a link to reset your password.")
                                        .font(PawlyFont.bodyMedium)
                                        .foregroundStyle(PawlyColors.slate)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal, Spacing.screenHorizontal)

                            VStack(spacing: 20) {
                                FormField(
                                    label: "Email",
                                    text: $email,
                                    placeholder: "you@example.com",
                                    keyboard: .emailAddress,
                                    autocapitalization: .never
                                )

                                if let error = authService.authError {
                                    ErrorBanner(message: error)
                                }

                                Button {
                                    Task {
                                        let success = await authService.resetPassword(email: email)
                                        if success {
                                            didSend = true
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        if authService.isLoading {
                                            ProgressView()
                                                .tint(.white)
                                                .scaleEffect(0.8)
                                        }
                                        Text("Send reset link")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                }
                                .buttonStyle(PawlyPrimaryButtonStyle())
                                .disabled(!canSubmit || authService.isLoading)
                                .opacity(canSubmit ? 1.0 : 0.55)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                                    .fill(PawlyColors.surface)
                                    .shadow(color: .black.opacity(0.04), radius: 24, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                                    .stroke(PawlyColors.hairline, lineWidth: 0.75)
                            )
                            .padding(.horizontal, Spacing.screenHorizontal)
                        } else {
                            VStack(spacing: 24) {
                                ZStack {
                                    Circle()
                                        .fill(PawlyColors.sageSoft)
                                        .frame(width: 88, height: 88)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(PawlyColors.sage)
                                }

                                VStack(spacing: 8) {
                                    Text("Check your inbox")
                                        .font(PawlyFont.headingLarge)
                                        .foregroundStyle(PawlyColors.ink)
                                    Text("We've sent a password reset link to \(email).")
                                        .font(PawlyFont.bodyMedium)
                                        .foregroundStyle(PawlyColors.slate)
                                        .multilineTextAlignment(.center)
                                }

                                Button("Back to Log In") {
                                    dismiss()
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                        .fill(PawlyColors.forest)
                                )
                            }
                            .padding(.horizontal, Spacing.screenHorizontal)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, Spacing.screenVertical)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !didSend {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(PawlyColors.slate)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Auth") {
    AuthView()
        .environmentObject(AuthService.shared)
}
