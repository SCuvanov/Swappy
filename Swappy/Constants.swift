//
//  Constants.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/6/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Cell {
        static let CELL_IDENTIFIER = "ReusableCell"
        static let ITEM_CELL_NIB_NAME = "ItemTableViewCell"
    }
    
    struct Segue {
        static let LOGIN_TO_MAIN = "LoginToMain"
        static let LOGIN_TO_REGISTER = "LoginToRegister"
        static let REGISTER_TO_MAIN = "RegisterToMain"
    }
    
    struct FirebaseErrorCodes {
        static let INVALID_EMAIL = 17008
        static let INVALID_PASSWORD = 17009
        static let USER_NOT_FOUND = 17011
    }
    
    struct FirebaseFirestore {
        static let COLLECTION_ITEM = "items"
        static let ITEM_NAME_FIELD = "name"
        static let ITEM_COUNT_FIELD = "count"
        static let ITEM_DATE_CREATED_FIELD = "date_created"
        static let ITEM_OWNER_FIELD = "owner"
        static let ITEM_CATEGORY_FIELD = "category"
        static let ITEM_STATUS_FIELD = "status"
    }
}
