//
//  SearchCriteria.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/11/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import Foundation

struct ItemSearchCriteria {
    var owner: String
    var category: String
    var skipOwner: Bool = false
    var filterAvailable: Bool = false
}
