//
//  SearchRespone.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/29.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import Foundation

struct SearchRespone: Codable {
    //var id: String = UUID().uuidString
    var total: NSInteger
    var total_pages: NSInteger
    var results: [Results]
}
