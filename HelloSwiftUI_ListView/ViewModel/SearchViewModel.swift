//
//  SearchViewModel.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/29.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import UIKit

class SearchViewModel: ObservableObject, Identifiable {
    
    private let unsplashFetcher: UnsplashFetcher
    private var disposables = Set<AnyCancellable>()
    
    init(unsplashFetcher: UnsplashFetcher) {
      self.unsplashFetcher = unsplashFetcher
    }
    
    var searchPublisher = PassthroughSubject<Void, RequestError>()
    var searchResponePublisher = PassthroughSubject<Void, RequestError>()
    let manager: APIManager = APIManager()
    
    @Published var posts: [Results] = [] {
        didSet {
            searchResponePublisher.send()
        }
    }
    
    @Published var isLoading: Bool = true {
        didSet {
            searchResponePublisher.send()
        }
    }
   
    var imageSearchBackgroundQueue: DispatchQueue = DispatchQueue(label: "imageSearchBackgroundQueue")
    
    
    func search(_ keyWord: String, _ page:String) {
        
        self.unsplashFetcher
        .searchPhoto(keyWord: keyWord, page: page)
        //.map(UnsplashRowViewModel.init)
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveSubscription: { _ in
            DispatchQueue.main.async {
              print("handleEvents received the data")
            }
        }, receiveCompletion: { [weak self] _ in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }, receiveCancel: {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        })
        .subscribe(on: self.imageSearchBackgroundQueue)
        .sink(receiveCompletion: { [weak self] completion in
            print(".sink() received the completion:", String(describing: completion))
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.isLoading = false
                print(error.localizedDescription)
            }
        }, receiveValue: { [weak self] posts in
            DispatchQueue.main.async {
                self?.isLoading = false
                if ((self?.posts.count)! > 0) {
                    self?.posts += posts.results
                } else {
                   self?.posts = posts.results
                }
            }
        })
        .store(in: &self.disposables)
    }
    
    func cancel() {
        self.disposables.forEach {
            $0.cancel()
        }
    }
}
