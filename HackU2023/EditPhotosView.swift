import SwiftUI

struct EditPhotosView: View {
    @State var imageKeys: [String] = []
    @State private var selectedImages: Set<String> = []
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        // 画像の表示
                        ForEach(imageKeys, id: \.self) { key in
                            if let image = retrieveImage(forKey: key) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .cornerRadius(10)
                                    .overlay(
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .border(selectedImages.contains(key) ? Color.blue : Color.clear, width: 3)
                                    )
                                    .onTapGesture {
                                        if selectedImages.contains(key) {
                                            selectedImages.remove(key)
                                        } else {
                                            selectedImages.insert(key)
                                        }
                                    }
                            }
                        }
                        .padding()
                        
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("削除") {
                    showingDeleteAlert = !selectedImages.isEmpty
                }
                .disabled(selectedImages.isEmpty)
            }
        }
        .navigationBarTitle("画像一覧", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadImages()
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("削除の確認"),
                message: Text("選択した画像を削除しますか？"),
                primaryButton: .destructive(Text("削除")) {
                    deleteSelectedImages()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // 画像を読み込む
    func loadImages() {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil)
            imageKeys = fileURLs.compactMap { $0.lastPathComponent }.filter { $0.hasSuffix(".png") }
        } catch {
            print("Error while enumerating files \(documentURL.path): \(error.localizedDescription)")
        }
    }
    
    // 画像をドキュメントディレクトリから読み出す
    func retrieveImage(forKey key: String) -> UIImage? {
        let filePath = self.filePath(forKey: key)
        if let fileData = FileManager.default.contents(atPath: filePath.path) {
            return UIImage(data: fileData)
        }
        return nil
    }
    
    // キーに対応するファイルパスを取得する
    func filePath(forKey key: String) -> URL {
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentURL.appendingPathComponent(key)
    }

    func deleteSelectedImages() {
        DispatchQueue.global(qos: .background).async {
            let fileManager = FileManager.default
            for key in self.selectedImages {
                let filePath = self.filePath(forKey: key)
                do {
                    try fileManager.removeItem(at: filePath)
                } catch {
                    DispatchQueue.main.async {
                        print("Error deleting image: \(error)")
                    }
                }
            }

            DispatchQueue.main.async {
                self.imageKeys.removeAll { self.selectedImages.contains($0) }
                self.selectedImages.removeAll()
            }
        }
    }



}


