import SwiftUI
import Lottie

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool
    
    init(isOnboardingComplete: Binding<Bool> = .constant(false)) {
        self._isOnboardingComplete = isOnboardingComplete
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        viewModel.skipOnboarding()
                        isOnboardingComplete = true
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
                
                // Page content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            // Lottie animation from local files
                            LottieView(animation: .named(viewModel.pages[index].animationName))
                                .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
                                .frame(width: 280, height: 280)
                                .padding()
                            
                            Text(viewModel.pages[index].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(viewModel.pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.bottom, 50)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            viewModel.previousPage()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .padding(16)
                                .background(Color.gray)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.nextPage()
                        if viewModel.isOnboardingComplete {
                            isOnboardingComplete = true
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .padding(16)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .onChange(of: viewModel.isOnboardingComplete) { oldValue, newValue in
            if newValue {
                isOnboardingComplete = true
            }
        }
    }
}

#Preview {
    OnboardingView()
} 
