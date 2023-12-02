//
//  HomeView.swift
//  HackU2023
//
//  Created by 坂井泰吾 on 2023/12/02.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: "home.jpg")!)
                .resizable()
                .scaledToFit()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
