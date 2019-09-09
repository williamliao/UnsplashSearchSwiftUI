//
//  ContentView.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/27.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var goSearchView:Bool = false
    
    @ObservedObject var viewModel: UnsplashViewModel
 
    @ObservedObject var searchViewModel: SearchViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    var searchButton: some View {
           Button(action: { self.goSearchView.toggle() }) {
            showSearchModelView(searchViewModel: searchViewModel)
           }
       }
    
    var body: some View {
        
        LoadingView(isShowing: .constant(viewModel.isLoading)) {
            NavigationView {
                     GeometryReader { geometry in
                         if self.verticalSizeClass == .regular {
                             VStack {
                                 // List inside the navigationController
                                         List {
                                            
                                             // loop through all the posts and create a post view for each item
                                             // here post is uniquely identified by property 'id'
                                            
                                            ForEach(self.viewModel.posts) { post in
                                               
                                                NavigationLink(destination: ImageDetailView(post: post)) {
                                                    //ImageView(post: post)
                                                    ImageView(post: post).frame(width: geometry.size.width,
                                                    height: geometry.size.height)
                                                }
                                            }
                                            .onDelete(perform: self.delete)
                                            .onMove(perform: self.move)
                                         
                                         }
                                 
                                            .navigationBarItems(leading: EditButton(), trailing: self.searchButton)
                                       
                                         .navigationBarTitle(Text("Home"))
                             }
                         } else {
                             VStack {
                                 // List inside the navigationController
                                         List {
                                        
                                             // loop through all the posts and create a post view for each item
                                             // here post is uniquely identified by property 'id'
                                             ForEach(self.viewModel.posts) { post in
                                                 
                                                 NavigationLink(destination: ImageDetailView(post: post)) {
                                                     ImageView(post: post).frame(width: geometry.size.width,
                                                     height: geometry.size.height)
                                                 }
                                             }
                                 
                                         }
                                        // set navbar title
                                         .navigationBarTitle(Text("Home"))
                             }
                         }
                     }
                 }
            
            .onAppear(perform: self.viewModel.onAppear)
            .onDisappear(perform: self.viewModel.onDisappear)
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.viewModel.posts.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.viewModel.posts.move(fromOffsets: source, toOffset: destination)
    }
}

struct showSearchModelView: View {
    @State private var showModal = false
    
    @ObservedObject var searchViewModel: SearchViewModel
    
    var body: some View {
        VStack {
            Button("Search") {
                self.showModal = true
                
            }
        }
        .sheet(isPresented: $showModal, onDismiss: {
            print(self.showModal)
        }) {
            SearchImageListView(searchViewModel: self.searchViewModel)
        }
      
    }
}

/*
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: UnsplashViewModel(), searchViewModel: SearchViewModel())
    }
}
#endif*/
