import SwiftUI
import CoreData
import SwiftyUpdateKit

struct StartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ViViTUser.level, ascending: true)],
        animation: .default)
    private var userSettings: FetchedResults<ViViTUser>
    
    @State private var isActive_main = false
    @State private var isActive_setup = false
    @State private var isTextVisible = true
    @State private var selectedTab: Tab = .home

    let screen: CGRect = UIScreen.main.bounds

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Hacku_start")
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 2), contentMode: .fill)
                VStack {
                    GeometryReader { geometry in
                        Button(action: {
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
                checkVersionAndShowReleaseNotes()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func checkVersionAndShowReleaseNotes() {
        SUK.checkVersion(VersionCheckConditionAlways(), newRelease: { newVersion, releaseNotes, firstUpdated in
            DispatchQueue.main.async {
                let hostingController = UIHostingController(rootView: ReleaseNotesView(releaseNotes: releaseNotes ?? "", version: newVersion ?? ""))
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    rootViewController.present(hostingController, animated: true, completion: nil)
                }
            }
        }) {
            SUK.requestReview(RequestReviewConditionAlways())
        }
    }
}

struct ReleaseNotesView: View {
    let releaseNotes: String
    let version: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                Text(releaseNotes)
                    .padding()
            }
            .navigationBarTitle("Version \(version)", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
