//
//  SelectFunctionView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/07.
//

import SwiftUI

struct SelectFunctionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var userSettings: FetchedResults<ViViTUser>

    @State private var isActiveScore = false
    @State private var isActiveOne = false
    @State private var isActive1Recommend = false
    @State private var showAlert = false  // アラート表示用の状態

    let screen: CGRect = UIScreen.main.bounds

    @State private var selectedImagesPair: [[UIImage]] = [[]]
    @State private var imageurl: [URL] = []

    var body: some View {
        ZStack {
            Image("Hacku_select")
                .resizable()
                .frame(maxWidth: screen.width / 0.9)
                .frame(maxHeight: screen.height / 0.9)
            VStack {
                Button("コーディネート提案") {
                    if selectedImagesPair.isEmpty || selectedImagesPair.allSatisfy({ $0.isEmpty }) {
                        // selectedImagesPairが空の場合、アラートを表示
                        showAlert = true
                    } else {
                        // selectedImagesPairに画像がある場合、画面遷移
                        isActive1Recommend = true
                    }
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
                    // imageurl配列が空であるか、全ての要素がnilの場合にアラートを表示
                    if imageurl.isEmpty || !imageurl.contains(where: { $0 != nil }) {
                        showAlert = true
                    } else {
                        // 少なくとも1つの有効なURLが含まれている場合、画面遷移
                        showAlert = false
                        isActiveOne = true
                    }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("エラー"),
                message: Text("画像がありません。下の「アルバム」から服を選択・保存することで、その中からベストな組み合わせをを選択します。"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear{
            selectedImagesPair = convertURLsToUIImages(urls: generateCombinations())
            imageurl = checkExistUrl()
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



