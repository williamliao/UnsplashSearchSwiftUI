//
//  SearchImageRow.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/9/5.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import SwiftUI

struct SearchImageRow: View {
    

    @ObservedObject var searchViewModel: SearchViewModel
    
    /// post
    @State var Size: CGSize
    
    var body: some View {
        ForEach(self.searchViewModel.posts) { post in
          
            SearchImageView(post: post).frame(width: self.Size.width,
                                              height: self.Size.height)
        }
    }
}

struct SearchImageRow_Previews: PreviewProvider {
    static var previews: some View {
        SearchImageRow(searchViewModel: SearchViewModel(unsplashFetcher: UnsplashFetcher()), Size: CGSize.zero)
    }
}
