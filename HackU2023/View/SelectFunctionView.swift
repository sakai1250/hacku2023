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
    @State private var isActive1Recommend = false

    let screen: CGRect = UIScreen.main.bounds

    @State private var selectedImagesPair: [[UIImage]] = [[]]

    var body: some View {
        ZStack {
            Image("Hacku_select")
                .resizable()
                .frame(maxWidth: screen.width / 0.9)
                .frame(maxHeight: screen.height / 0.9)
            VStack {
                Button("コーディネート提案") {
                    isActive1Recommend = true
                }
                .padding()
                .background(Color(red: 1.0, green: 182/255, blue: 193/255))
                .foregroundColor(.black)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: screen.width / 2)
                .frame(maxHeight: screen.height / 5)
                .navigationDestination(isPresented: $isActive1Recommend) {
                    OnetapRecommendView(selectedImagesPair: $selectedImagesPair)
                }

                Button("おしゃれ度測定") {
                    isActiveScore = true
                }
                .padding()
                .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                .foregroundColor(.black)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: screen.width / 2)
                .frame(maxHeight: screen.height / 5)
                .navigationDestination(isPresented: $isActiveScore) {
                    ImageScoreView()
                }
                Button("購入サポート") {
                    isActiveOne = true
                }
                .padding()
                .background(Color(red: 0.0, green: 0.6, blue: 0.9))
                .foregroundColor(.black)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: screen.width / 2)
                .frame(maxHeight: screen.height / 5)
                .navigationDestination(isPresented: $isActiveOne) {
                    PickOneView()
                }
            }
        }
        .onAppear{
            selectedImagesPair = convertURLsToUIImages(urls: generateCombinations())
        }
    }
}

func convertURLsToUIImages(urls: [[URL]]) -> [[UIImage]] {
    return urls.map { urlArray in
        urlArray.compactMap { url in
            UIImage(contentsOfFile: url.path) // URLからUIImageを生成
        }
    }
}



struct SelectFunctionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectFunctionView()
    }
}
