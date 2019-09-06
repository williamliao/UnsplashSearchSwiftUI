//
//  SearchImageView.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/9/3.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import UIKit

import SwiftUI
import URLImage

/// PostView
struct SearchImageView: View {
    
    let post: Results
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            URLImage(URL.init(string: post.urls.thumb)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
    }
}

