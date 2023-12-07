//
//  SelectFunctionView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/07.
//

import SwiftUI

struct SelectFunctionView: View {
    @State private var isActiveScore = false
    @State private var isActiveOne = false

    let screen: CGRect = UIScreen.main.bounds

    var body: some View {
        ZStack {
            Image("Hacku_select")
                .resizable()
                .frame(maxWidth: screen.width / 0.9)
                .frame(maxHeight: screen.height / 0.9)
            VStack {
                Button("服を採点する") {
                    isActiveScore = true
                }
                .padding()
                .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: screen.width / 2)
                .frame(maxHeight: screen.height / 5)
                .navigationDestination(isPresented: $isActiveScore) {
                    ImageScoreView()
                }
                Button("ペアを決める") {
                    isActiveOne = true
                }
                .padding()
                .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: screen.width / 2)
                .frame(maxHeight: screen.height / 5)
                .navigationDestination(isPresented: $isActiveOne) {
                    PickOneView()
                }
            }
        }
    }
}

struct SelectFunctionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectFunctionView()
    }
}
