//
//  DataManager.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/9/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


struct DataManager {
    
    let db = Firestore.firestore()
    
    func addItemToDB(item: Item) {
        db.collection(Constants.FirebaseFirestore.COLLECTION_ITEM).addDocument(data: [
            Constants.FirebaseFirestore.ITEM_NAME_FIELD : item.name,
            Constants.FirebaseFirestore.ITEM_COUNT_FIELD : item.count,
            Constants.FirebaseFirestore.ITEM_OWNER_FIELD : item.owner,
            Constants.FirebaseFirestore.ITEM_CATEGORY_FIELD : item.category,
            Constants.FirebaseFirestore.ITEM_STATUS_FIELD : item.status,
            Constants.FirebaseFirestore.ITEM_DATE_CREATED_FIELD: Date().timeIntervalSince1970]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore: \(e)")//TODO: Alert Issue with Update
                }
        }
    }
    
    func removeItemFromDB(item: Item) {
        if let id = item.id {
            db.collection(Constants.FirebaseFirestore.COLLECTION_ITEM).document(id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
    
    func updateItemInDB(item: Item) {
        //TODO: Update the item some day.
    }
    
    mutating func listenForItems(searchCriteria: ItemSearchCriteria, completion: @escaping (_ items: [Item])->Void){

        var query : Query = db.collection(Constants.FirebaseFirestore.COLLECTION_ITEM)
        
        if !searchCriteria.skipOwner {
            query = query.whereField(Constants.FirebaseFirestore.ITEM_OWNER_FIELD, isEqualTo: searchCriteria.owner)
        }
        
        query = query.whereField(Constants.FirebaseFirestore.ITEM_CATEGORY_FIELD, isEqualTo: searchCriteria.category)
        query = query.order(by: Constants.FirebaseFirestore.ITEM_DATE_CREATED_FIELD, descending: false)
        query.addSnapshotListener() { (querySnapshot, err) in
            
            var items: [Item] = []
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let name = document.data()[Constants.FirebaseFirestore.ITEM_NAME_FIELD] as? String,
                        let owner = document.data()[Constants.FirebaseFirestore.ITEM_OWNER_FIELD] as? String,
                        let count = document.data()[Constants.FirebaseFirestore.ITEM_COUNT_FIELD] as? Int,
                        let category = document.data()[Constants.FirebaseFirestore.ITEM_CATEGORY_FIELD] as? String,
                        let status = document.data()[Constants.FirebaseFirestore.ITEM_STATUS_FIELD] as? String{
                        
                        if searchCriteria.skipOwner && searchCriteria.owner == owner {
                            continue
                        } else {
                            items.append(Item(id: document.documentID, name: name, owner: owner, count: count, category: category, status: status))
                        }
                    }
                }
            }
            completion(items)
        }
    }
}
