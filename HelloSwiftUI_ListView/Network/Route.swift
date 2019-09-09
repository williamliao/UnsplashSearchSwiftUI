//
//  Route.swift
//  AnimeWindow
//
//  Created by William Liao on 2019/8/9.
//  Copyright © 2019 William Liao. All rights reserved.
//

import Foundation

public struct Route {
    let endpoint: String
}

public struct Routes {
    static let get = Route(endpoint: "/photos/random")
    static let search = Route(endpoint: "/search/photos")
}
