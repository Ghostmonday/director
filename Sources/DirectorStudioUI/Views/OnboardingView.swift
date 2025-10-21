import SwiftUI
import DirectorStudio

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        title: "Welcome to DirectorStudio",
                        subtitle: "Transform your stories into cinematic videos",
                        imageName: "video.badge.plus",
                        description: "Write your story and let AI bring it to life with stunning visuals and professional quality."
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        title: "AI-Powered Pipeline",
                        subtitle: "Advanced story analysis and video generation",
                        imageName: "brain.head.profile",
                        description: "Our AI analyzes your narrative structure, characters, and themes to create compelling video content."
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        title: "Professional Results",
                        subtitle: "Export in multiple formats",
                        imageName: "square.and.arrow.up",
                        description: "Share your creations anywhere with high-quality exports and seamless integration."
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Continue button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text(currentPage == 2 ? "Get Started" : "Next")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 40)
                }
                .scaleEffect(currentPage == 2 ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon with animated background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: imageName)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)
                    )
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: imageName)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
            Spacer()
        }
    }
}

/// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}