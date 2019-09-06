//
//  imageView.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/27.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import Foundation
import SwiftUI
import URLImage

/// PostView
struct ImageView: View {
    
    let post: Response
    
    var body: some View {
        
            VStack(alignment: .leading, spacing: 20) {
                      
                      URLImage(URL.init(string: post.urls.regular)!)
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .clipped()
                      .animation(.spring())
            }
    }
}
