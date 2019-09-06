//
//  SearchBar.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/9/5.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var viewModel: SearchViewModel
    
    var placeholder:String?
    
    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        var viewModel: SearchViewModel

        init(text: Binding<String>, viewModel: SearchViewModel) {
            _text = text
            self.viewModel = viewModel
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.becomeFirstResponder()
            guard let searchText = searchBar.text else {
                return
            }
            text = searchText
        }
        
        func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                return true
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let searchText = searchBar.text else {
                return
            }
            viewModel.search(searchText, "1")
            searchBar.resignFirstResponder()
        }
        
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, viewModel: viewModel)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {

        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
