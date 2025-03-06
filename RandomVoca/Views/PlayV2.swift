import SwiftUI
import AVFoundation  // 발음 재생용

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
    @State private var isWordChanging: Bool = false
    @State private var cardOffset: CGFloat = 0  // 카드의 위치 제어 변수
    
    // Feedback generator & Speech synthesizer
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
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
            
            // 전체 콘텐츠: 카드 및 스와이프 안내를 중앙에 배치
            VStack {
                Spacer()  // 상단 여백
                
                // 카드 뷰 (중앙)
                ZStack {
                    VStack(spacing: 16) {
                        // 단어 또는 뜻 텍스트
                        Text(showMeaning ? displayWordMeaning : displayWordName)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // 발음 재생 버튼 (스피커 아이콘)
                        Button(action: {
                            playPronunciation()
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(30)
                    .frame(maxWidth: .infinity, maxHeight: 280)
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
                .offset(y: cardOffset)
                .padding(.horizontal)
                
                // 카드 바로 아래 스와이프 안내 UI
                VStack(spacing: 6) {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    
                    Text("스와이프하여 다음 문장")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                .padding(.top, 16)
                
                Spacer()  // 중앙 정렬을 위한 하단 여백 (뜻보기 버튼은 별도 배치)
            }
            
            // 하단에 뜻 보기 버튼을 고정
            VStack {
                Spacer()
                Button(action: {
                    flipCard()  // 뜻 보기 / 단어 보기 전환
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
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        // 아래에서 위로 스와이프하면 showNextWord() 호출
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        showNextWord()
                    }
                }
        )
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
    
    // MARK: - Haptics 준비
    private func prepareHaptics() {
        feedbackGenerator.prepare()
    }
    
    // MARK: - 무작위 인덱스 초기화
    private func initializeRandomIndices() {
        guard !modelData.words.isEmpty else { return }
        randomIndices = Array(0..<modelData.words.count).shuffled()
        currentWordIndex = -1
    }
    
    // MARK: - 카드 뒤집기 효과 (뜻 보기/단어 보기 전환)
    private func flipCard() {
        feedbackGenerator.impactOccurred(intensity: 0.4)
        showMeaning.toggle()
    }
    
    // MARK: - 빠른 슬라이드 애니메이션을 통한 다음 단어 표시
    private func showNextWord() {
        guard !isWordChanging else { return }
        isWordChanging = true
        feedbackGenerator.impactOccurred(intensity: 0.5)
        
        // 카드가 사라질 때 뜻을 숨김 (전 단어의 뜻이 보이는 현상 방지)
        withAnimation(.easeIn(duration: 0.05)) {  // ⬅️ 애니메이션 속도 0.05초로 단축
            cardOffset = -UIScreen.main.bounds.height
        }
        
        // 카드가 완전히 사라진 후에 showMeaning을 false로 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) {  // ⬅️ 지연 시간 단축
            showMeaning = false  // 뜻을 숨김 (전 단어가 보이는 문제 해결)
        }
        
        // 새로운 단어로 교체
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {  // ⬅️ 지연 시간 단축
            updateWordContent()
            cardOffset = UIScreen.main.bounds.height  // 카드 위치를 화면 아래로 이동
            
            // 카드가 다시 나타날 때는 단어만 보이도록
            withAnimation(.easeOut(duration: 0.05)) {  // ⬅️ 애니메이션 속도 0.05초로 단축
                cardOffset = 0  // 원래 위치로 복귀
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {  // ⬅️ 지연 시간 단축
                isWordChanging = false
            }
        }
    }
    
    // MARK: - 단어 내용 업데이트
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
