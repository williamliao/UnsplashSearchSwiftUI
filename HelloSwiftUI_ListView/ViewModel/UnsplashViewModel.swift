//
//  UnsplashViewModel.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/28.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

class UnsplashViewModel: ObservableObject, Identifiable {
    
    var imageURLPublisher = PassthroughSubject<Void, RequestError>()
    
    let manager: APIManager = APIManager()
   
    @Published var isLoading: Bool = true {
        didSet {
            imageURLPublisher.send()
        }
    }
   
    @Published
    var posts: [Response] = [] {
        didSet {
            imageURLPublisher.send()
        }
    }
    
    private var photoCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }

    deinit {
        photoCancellable?.cancel()
    }
    
    var imageBackgroundQueue: DispatchQueue = DispatchQueue(label: "ImageDownloadBackgroundQueue")
   
    private(set) lazy var onAppear: () -> Void = { [weak self] in
        guard let self = self else { return }
        
        let urlString = "https://api.unsplash.com/photos/random?client_id=\(self.manager.key)&count=20"
        
        if self.manager.key.isEmpty {
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.photoCancellable = URLSession.shared.publisher(for: request)
            .retry(3)
            .mapError({ (error) -> RequestError in
                return RequestError.request(error: error)
            })
            .decode(type: [Response].self, decoder: JSONDecoder())
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
            .subscribe(on: self.imageBackgroundQueue)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                print(".sink() received the completion:", String(describing: completion))
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] posts in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.posts = posts
                }
            })
    }
    
    private(set) lazy var onDisappear: () -> Void = { [weak self] in
        guard let self = self else { return }
        self.photoCancellable?.cancel()
    }
  
    func cancel() {
        if let task = self.photoCancellable {
            task.cancel()
        }
    }
}
