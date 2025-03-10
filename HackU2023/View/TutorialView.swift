import SwiftUI

// チュートリアル画面を表示するためのモデル
struct TutorialPage: Identifiable {
    let id = UUID()
    let imageName: String
    let description: String
}

// チュートリアルの状態を管理するためのクラス
class TutorialViewModel: ObservableObject {
    @Published var currentPage = 0
    let pages: [TutorialPage]
    
    init() {
        // ここに実際の画像名を追加してください
        self.pages = [
//            TutorialPage(imageName: "Tutrial0"),
//            TutorialPage(imageName: "Tutrial1"),
//            TutorialPage(imageName: "Tutrial2"),
//            TutorialPage(imageName: "Tutrial3"),
//            TutorialPage(imageName: "Tutrial4"),
        ]
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct TutorialView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject private var viewModel = TutorialViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var showTutorial: Bool
    let user: ViViTUser
    
    var body: some View {
        ZStack {
            // タブビュー
            TabView(selection: $viewModel.currentPage) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    ZStack {
                        Image(page.imageName)
                            .resizable()
                            .scaledToFit()
                        
                        Text(page.description)
                            .font(.system(size: 32))
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding()
                            .position(x: UIScreen.main.bounds.width / 2, y: 100)
                    }
                    .tag(index) // tagをZStackに移動
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // ナビゲーションボタン
            VStack {
                // Skipボタン
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Skip")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(25)
                    }
                    .padding()
                }
                
                Spacer()
                
                // 前へ/次へボタン
                HStack {
                    // 前へボタン
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                viewModel.currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    // 次へボタン
                    if viewModel.currentPage < viewModel.pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                viewModel.currentPage += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            completeTutorial()
                        }) {
                            Text("完了")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color.black.opacity(0.1))
    }
    
    // チュートリアル完了時の処理を追加
    private func completeTutorial() {
        user.tutrial = false
        try? managedObjectContext.save()
        showTutorial = false
        dismiss()
    }
}
//// プレビュー用
//struct TutorialView_Previews: PreviewProvider {
//    static var viewModel = TutorialViewModel()
//    
//    static var previews: some View {
//        TutorialView()
//    }
//}
