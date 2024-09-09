//
//  ContentView.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingAddButton = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .toolbar {
                NavigationLink(destination: NewScreenView()) {
                    Label("User Profile", systemImage: "plus")
                }
//                Button {
//                    showingAddButton.toggle()
//                } label: {
//                    Label("User Profile", systemImage: "plus")
//                }
            }
            .padding()
            .sheet(isPresented: $showingAddButton) {
                
            }
        }
    }
}

struct NewScreenView: View {
    var body: some View {
        VStack {
            Text("This is a new screen")
                .font(.largeTitle)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
