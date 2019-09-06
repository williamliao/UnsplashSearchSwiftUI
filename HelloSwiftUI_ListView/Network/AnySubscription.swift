//
//  AnySubscription.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/9/5.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import Foundation
import Combine

final class AnySubscription: Subscription {
    private let cancellable: Cancellable

    init(_ cancel: @escaping () -> Void) {
        cancellable = AnyCancellable(cancel)
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        cancellable.cancel()
    }
}
