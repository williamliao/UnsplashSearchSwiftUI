//
//  SearchImageListView.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/9/5.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import SwiftUI

struct SearchImageListView: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    @ObservedObject var searchViewModel: SearchViewModel
    
    @State private var searchText: String = ""
    
    @State var page: NSInteger = 1
    
    var body: some View {
        
        GeometryReader { geometry in
            
            if self.verticalSizeClass == .regular {
                VStack {
                   
                    SearchBar(text: self.$searchText, viewModel: self.searchViewModel)
                    List {
                        SearchImageRow(searchViewModel: self.searchViewModel, Size: CGSize(width: geometry.size.width * 0.70, height: geometry.size.width * 0.70))
                    }
                    Button(action: self.loadMore) {
                        Text("Lord More")
                        }
                        .onAppear {
                            DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 10)) {
                                self.loadMore()
                            }
                    }
                }
            } else {
                VStack {
                    SearchBar(text: self.$searchText, viewModel: self.searchViewModel)
                    
                    List {
                        SearchImageRow(searchViewModel: self.searchViewModel, Size: CGSize(width: geometry.size.width * 0.40, height: geometry.size.height))
                    }
                }
            }
        }
    }
    
    func loadMore() {
        //print("Load more...")
        page = page + 1
        searchViewModel.search(searchText, "\(page)")
    }
}

struct SearchImageListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchImageListView(searchViewModel: SearchViewModel())
    }
}
