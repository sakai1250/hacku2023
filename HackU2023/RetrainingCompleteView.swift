//
//  RetrainingCompleteView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI

struct RetrainingCompleteView: View {
    @State private var isActive = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("再学習完了")
                Button("ホームに戻る"){
                        isActive = true
                }
            }
            .navigationDestination(isPresented: $isActive) {
                MainView()
            }
        }
    }
}

struct RetrainingCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        RetrainingCompleteView()
    }
}