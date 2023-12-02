//
//  ContentView.swift
//  ml_update_task
//
//  Created by 坂井泰吾 on 2023/11/28.
//

import SwiftUI
import CoreData

struct StartView: View {
    @State private var isActive = false

    var body: some View {
        NavigationStack {
            VStack {
                Button("スタート") {
                    isActive = true
                }
            }
            .navigationDestination(isPresented: $isActive) {
                ViewController()
            }
        }
    }
}


struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
