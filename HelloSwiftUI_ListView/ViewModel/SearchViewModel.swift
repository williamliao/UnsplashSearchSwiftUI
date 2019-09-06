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
    
    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }

    deinit {
        searchCancellable?.cancel()
    }
    
    var imageSearchBackgroundQueue: DispatchQueue = DispatchQueue(label: "imageSearchBackgroundQueue")
    
    
    func search(_ keyWord: String, _ page:String) {
        
        var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos")!
                    urlComponents.queryItems = [
                        URLQueryItem(name: "page", value: page),
                        URLQueryItem(name: "query", value: keyWord),
                        URLQueryItem(name: "client_id", value: manager.key),
                        URLQueryItem(name: "per_page", value: "10")
                    ]
        
        if self.manager.key.isEmpty {
            return
        }
        
        guard let url = urlComponents.url else {
            return
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        self.searchCancellable = URLSession.shared.publisher(for: request)
             .retry(3)
             .decode(type: SearchRespone.self, decoder: JSONDecoder())
             .eraseToAnyPublisher()
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
    }
    
    func cancel() {
        if let task = self.searchCancellable {
            task.cancel()
        }
    }
}
