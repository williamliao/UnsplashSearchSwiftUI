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
    
    private let unsplashFetcher: UnsplashFetcher
    private var disposables = Set<AnyCancellable>()
    
    init(unsplashFetcher: UnsplashFetcher) {
      self.unsplashFetcher = unsplashFetcher
    }
    
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
   
    var imageBackgroundQueue: DispatchQueue = DispatchQueue(label: "ImageDownloadBackgroundQueue")
   
    private(set) lazy var onAppear: () -> Void = { [weak self] in
        guard let self = self else { return }
        
       self.unsplashFetcher
        .getPhotoFeed()
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
            .subscribe(on: self.imageBackgroundQueue)
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
                    self?.posts = posts
                }
            })
            .store(in: &self.disposables)
    }
    
    private(set) lazy var onDisappear: () -> Void = { [weak self] in
        guard let self = self else { return }
        self.disposables.forEach { $0.cancel() }
    }
  
    func cancel() {
        self.disposables.forEach {
            $0.cancel()
        }
    }
}
