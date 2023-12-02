//
//  PhotosView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI


struct PhotosView: View {
    @State var selection = 1
    
    var body: some View {
        VStack {
            // 上部のグリッドアイテム
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(0..<6) { _ in
                    Rectangle()
                        .frame(height: 100)
                        .cornerRadius(10)
                }
            }
            .padding()

            Spacer()
        }
    }
}


struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView()
    }
}
