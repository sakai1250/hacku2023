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
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                    .opacity(isTextVisible ? 1.0 : 0.0)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isTextVisible)
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
