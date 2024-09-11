//
//  Play.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import SwiftUI

struct Play: View {
    var words: [String]
    
    var body: some View {
        VStack {
            Text("/ˌjuːnɪˈvɜːrsəti/")
        }
        
        VStack {
            Color.red
        }
    }
}

#Preview {
    // UserDefaults에서 데이터를 안전하게 가져와서 처리
    let savedWords = UserDefaults.standard.array(forKey: "SavedWords") as? [String] ?? []
    return Play(words: savedWords)
}
