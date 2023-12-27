//
//  PaginatedScrollView.swift
//  SleepHabits
//
//  Created by Artemis Shlesberg on 2/21/23.
//

import SwiftUI

struct PaginatableScroll<Content: View>: View {
    
    let pageCount: Int
    let content: Content
       
    init(pageCount: Int, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self.content = content()
    }
    
    
    var body: some View {
        ScrollView {
            LazyHStack {
                TabView {
                    content
                    .padding(.all, 20)
                }
                .frame(width: UIScreen.main.bounds.width, height: 300)
                .tabViewStyle(PageTabViewStyle())
//                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
//                .indexViewStyle(PageIndexViewStyle())
            }
        }
    }
}

struct PaginatableScroll_Previews: PreviewProvider {
    static var previews: some View {
        PaginatableScroll(pageCount: 5) {
            ForEach(0..<5) { index in
                Rectangle()
                    .fill(Color.blue)
            }
        }
    }
}
