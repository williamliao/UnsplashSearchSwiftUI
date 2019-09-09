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
    case httpError(code: NSInteger)
    case otherError
    case parsing(description: String)
    case network(description: String)
    case sessionError(error: Error)
}

enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

protocol APIClient {
    func getPhotoFeed() -> AnyPublisher<[Response], RequestError>
    func searchPhoto(keyWord:String, page:String) -> AnyPublisher<SearchRespone, RequestError>
}

extension APIClient {
   
    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, RequestError> {
      let decoder = JSONDecoder()
 
      return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError { error -> RequestError in
            return RequestError.sessionError(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    func decodeCollections<T: Decodable>(_ data: Data) -> AnyPublisher<[T], RequestError> {
      let decoder = JSONDecoder()
         return Just(data)
            .decode(type: [T].self, decoder: decoder)
            .mapError { error -> RequestError in
                return RequestError.sessionError(error: error)
            }
            .eraseToAnyPublisher()
    }
}


class UnsplashFetcher: NSObject {
    lazy var session: URLSession = { [weak self] in
    let configuration = URLSessionConfiguration.default
     configuration.timeoutIntervalForResource = 60
    if #available(iOS 11, *) {
         configuration.waitsForConnectivity = true
    }
    let session = URLSession(
        configuration: configuration,
        delegate: self,
        delegateQueue: nil)
    return session
    }()
}

extension UnsplashFetcher: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error: \(String(describing: error?.localizedDescription))")
        
        task.cancel()
    }
    
    
}

extension UnsplashFetcher: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // waiting for connectivity, update UI, etc.
        
        if task.state == .running {
            print("URLSession:taskIsWaitingForConnectivity:")
        }
    }
}

private extension UnsplashFetcher {
    struct UnsplashAPI {
      static let scheme = "https"
      static let host = "api.unsplash.com"
      //static let path = "photos/random"
      static let key = ""
    }
   
    func makePhotoFeedComponents(
    ) -> URLComponents {
      var components = URLComponents()
      components.scheme = UnsplashAPI.scheme
      components.host = UnsplashAPI.host
        components.path = Routes.get.endpoint
      
      components.queryItems = [
        URLQueryItem(name: "count", value: "20"),
        URLQueryItem(name: "client_id", value: UnsplashAPI.key)
      ]
      
      return components
    }
    
    func makeSearchComponents(keyWord:String, page:String
    ) -> URLComponents {
      var components = URLComponents()
      components.scheme = UnsplashAPI.scheme
      components.host = UnsplashAPI.host
      components.path = Routes.search.endpoint
      
      components.queryItems = [
        URLQueryItem(name: "page", value: page),
        URLQueryItem(name: "query", value: keyWord),
        URLQueryItem(name: "client_id", value: UnsplashAPI.key),
        URLQueryItem(name: "per_page", value: "10")
      ]
      
      return components
    }
}

extension UnsplashFetcher: APIClient {
   
    func getPhotoFeed() -> AnyPublisher<[Response], RequestError> {
        return fetchDataCollections(with: makePhotoFeedComponents(), httpMethod: .get)
    }
    
    func searchPhoto(keyWord: String, page: String) -> AnyPublisher<SearchRespone, RequestError> {
        return fetch(with: makeSearchComponents(keyWord: keyWord, page: page), httpMethod: .get)
    }
    
    private func fetchDataCollections<T>(
        with components: URLComponents, httpMethod: HTTPMethod
    ) -> AnyPublisher<[T], RequestError> where T: Decodable {
        guard let url = components.url else {
          let error = RequestError.network(description: "Couldn't create URL")
          return Fail(error: error).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if httpMethod != .get {
            request.httpMethod = httpMethod.rawValue
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
              .network(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
               self.decodeCollections(pair.data)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetch<T>(
      with components: URLComponents, httpMethod: HTTPMethod
    ) -> AnyPublisher<T, RequestError> where T: Decodable {
        guard let url = components.url else {
          let error = RequestError.network(description: "Couldn't create URL")
          return Fail(error: error).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if httpMethod != .get {
           request.httpMethod = httpMethod.rawValue
        }
        
        return session.dataTaskPublisher(for: request)
          .mapError { error in
            .network(description: error.localizedDescription)
          }

         .flatMap(maxPublishers: .max(1)) { pair in
            self.decode(pair.data)
         }
        .eraseToAnyPublisher()
    }
}

struct RequestPublisher: Publisher {

    typealias Output = Data
    typealias Failure = RequestError

    let session: URLSession
    let request: URLRequest

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {

        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                let httpReponse = response as? HTTPURLResponse
                if let data = data, let httpReponse = httpReponse, 200 ..< 300 ~= httpReponse.statusCode {

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
