//
//  Item.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/7/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import Foundation

struct Item {
    var id: String?
    var name: String
    var owner: String
    var count: Int = 0
    var category: String
    var status: String = Status.AVAILABLE
    var selected: Bool = false
    
    struct Category {
        static let STOCK = "Stock"
        static let NEED = "Need"
    }
    
    struct Status {
        static let AVAILABLE = "Available"
        static let UNAVAILABLE = "Unavailable"
        static let PENDING_TRADE = "Pending Trade"
    }
}
