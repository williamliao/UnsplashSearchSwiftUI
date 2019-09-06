//
//  ApiClient.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/29.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum RequestError: Error {
    case request(error: Error)
    case http(code: NSInteger, error: Error?)
    case otherError
}

struct APIManager {
    let key:String = ""
}

struct RequestPublisher: Publisher {
    
    typealias Output = Data
    typealias Failure = RequestError
 
    let session: URLSession
    let request: URLRequest
 
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                let httpReponse = response as? HTTPURLResponse
                if let data = data, let httpReponse = httpReponse, 200..<300 ~= httpReponse.statusCode {
                    
                    _ = subscriber.receive(data)
                    subscriber.receive(completion: .finished)
                } else if let httpReponse = httpReponse {
                    
                    let error = RequestError.http(code: httpReponse.statusCode, error: error)
                    subscriber.receive(completion: .failure(error))
                } else {
                    
                    let error = RequestError.otherError
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
 
        let subscription = RequestSubscription(combineIdentifier: CombineIdentifier(), task: task)
        subscriber.receive(subscription: subscription)
 
        task.resume()
    }
}

struct RequestSubscription: Subscription {
    let combineIdentifier: CombineIdentifier
    let task: URLSessionTask
 
    func request(_ demand: Subscribers.Demand) {}
 
    func cancel() {
        task.cancel()
    }
}

extension URLSession {
    func publisher(for request: URLRequest) -> RequestPublisher {
        return RequestPublisher(session: self, request: request)
    }
}




