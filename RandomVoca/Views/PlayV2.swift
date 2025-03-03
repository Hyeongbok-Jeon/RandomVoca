import SwiftUI
import AVFoundation  // AVFoundation 임포트 (발음 재생용)

struct PlayV2: View {
    @EnvironmentObject var modelData: ModelDataV2
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @Environment(\.colorScheme) var colorScheme

    // Word display states
    @State private var displayWordName: String
    @State private var displayWordPronunciation: String
    @State private var displayWordMeaning: String
    @State private var currentWordIndex: Int = -1
    @State private var randomIndices: [Int] = []
    
    // UI states
    @State private var showMeaning: Bool = false
    @State private var textOpacity: Double = 1.0
    @State private var isWordChanging: Bool = false
    
    // Animation settings
    private let fadeDuration: Double = 0.2
    
    // Feedback generator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // Speech synthesizer
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    init(initialWord: String = "") {
        _displayWordName = State(initialValue: initialWord)
        _displayWordPronunciation = State(initialValue: initialWord)
        _displayWordMeaning = State(initialValue: initialWord)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
//                HStack {
//                    Text("\(currentWordIndex + 1 > 0 ? currentWordIndex + 1 : 0) / \(modelData.words.count)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    Spacer()
//                    
//                    ProgressView(value: Double(currentWordIndex + 1) / Double(max(1, modelData.words.count)))
//                        .progressViewStyle(LinearProgressViewStyle())
//                        .frame(width: 100)
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
                
                Spacer()
                
                ZStack {
                    VStack(spacing: 24) {
                        Text(showMeaning ? displayWordMeaning : displayWordName)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack(spacing: 8) {
//                            Text(displayWordPronunciation)
//                                .font(.system(size: 22, design: .serif))
//                                .foregroundColor(.secondary)
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 6)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color(UIColor.secondarySystemBackground))
//                                )
                            
                            Button(action: {
                                playPronunciation()  // 발음 재생
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(30)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .opacity(textOpacity)
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        flipCard()  // 뜻 보기/단어 보기 전환
                    }) {
                        Text(showMeaning ? "문장 보기" : "뜻 보기")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            .shadow(radius: 2)
                    }
                    
                    Button(action: {
                        showNextWord()  // 다음 단어로 이동
                    }) {
                        Text("다음 문장")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            prepareHaptics()
            if displayWordName.isEmpty {
                initializeRandomIndices()
                showNextWord()
            }
        }
    }
    
    // MARK: - 발음 재생 함수
    private func playPronunciation() {
        let utterance = AVSpeechUtterance(string: displayWordName)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - Prepare haptics
    private func prepareHaptics() {
        feedbackGenerator.prepare()
    }
    
    // MARK: - Initialize random indices
    private func initializeRandomIndices() {
        guard !modelData.words.isEmpty else { return }
        randomIndices = Array(0..<modelData.words.count).shuffled()
        currentWordIndex = -1
    }
    
    // MARK: - Flip card effect (뜻 보기/단어 보기 전환)
    private func flipCard() {
        feedbackGenerator.impactOccurred(intensity: 0.4)
        showMeaning.toggle()
    }
    
    // MARK: - Show next word (다음 단어 시 단어 보기 모드로 전환)
    private func showNextWord() {
        guard !isWordChanging else { return }
        
        isWordChanging = true
        feedbackGenerator.impactOccurred(intensity: 0.5)
        
        // opacity를 0으로 설정하여 이전 단어를 숨깁니다.
        withAnimation(.easeOut(duration: fadeDuration)) {
            textOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            // 새로운 단어로 변경합니다.
            updateWordContent()
            
            // showMeaning 상태를 바꿔서 단어 보기 모드로 돌아갑니다.
            showMeaning = false
            
            // opacity를 1로 설정하면서 애니메이션을 적용합니다.
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                textOpacity = 1.0
            }
            
            // 애니메이션 종료 후 isWordChanging을 false로 설정
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isWordChanging = false
            }
        }
    }
    
    // MARK: - Update word content
    private func updateWordContent() {
        guard !modelData.words.isEmpty else { return }
        
        if currentWordIndex >= randomIndices.count - 1 || randomIndices.isEmpty {
            initializeRandomIndices()
        }
        
        currentWordIndex += 1
        let wordIndex = randomIndices[currentWordIndex % randomIndices.count]
        let currentWord = modelData.words[wordIndex]
        
        displayWordName = currentWord.name ?? ""
        displayWordMeaning = currentWord.meaning ?? "No meaning available"
    }
}

#if DEBUG
#Preview {
    let modelData = ModelDataV2()
    return PlayV2()
        .environmentObject(modelData)
        .preferredColorScheme(.dark)
}
#endif
