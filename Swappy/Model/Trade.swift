//
//  Trade.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/12/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import Foundation

struct Trade {
    var itemsToTrade: [Item]
    var itemsToReceive: [Item]
    var proposingOwner: String
    var receivingOwner: String
    var status: String
    
    struct Status {
        static let OPEN = "Open"
        static let PENDING = "Pending"
        static let COMPLETE = "Complete"
    }
}
