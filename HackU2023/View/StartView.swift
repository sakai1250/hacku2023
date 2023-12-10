import SwiftUI
import CoreData

struct StartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var userSettings: FetchedResults<ViViTUser>
    
    @State private var isActive_main = false
    @State private var isActive_setup = false
    @State private var isTextVisible = true
    
    let screen: CGRect = UIScreen.main.bounds

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Hacku_start")
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
//                    .frame(maxWidth: screen.width / 0.8)
//                    .frame(maxHeight: screen.height / 0.8)
                VStack {
                    GeometryReader { geometry in
                        Button(action: {
                            // Core DataからViViTUserエンティティの最初のレコードを確認
                            if let firstUserSetting = userSettings.first, firstUserSetting.name != nil {
                                isActive_main = true
                            } else {
                                isActive_setup = true
                            }
                        }) {
                            Color.clear
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .navigationDestination(isPresented: $isActive_main) {
                            MainView().environment(\.managedObjectContext, viewContext)
                        }
                        .navigationDestination(isPresented: $isActive_setup) {
                            SetupView().environment(\.managedObjectContext, viewContext)
                        }
                    }
                    Text("Tap to START")
                        .font(.headline)
                        .fontWeight(.bold)
                        .opacity(isTextVisible ? 1.0 : 0.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isTextVisible)
                }
                .offset(y: -screen.height / 10)

            }
            .onAppear {
                isTextVisible.toggle()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
