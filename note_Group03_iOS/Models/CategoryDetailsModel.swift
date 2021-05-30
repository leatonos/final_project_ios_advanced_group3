//
//  CategoryDetailsModel.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 18/05/21.
//

import Foundation

struct CategoryDetailsModel {
    var id: Int!
    var categoryName: String!
    var addedDate: String!

    init(_ dict:[String: Any]) {
        id = dict["id"] as? Int ?? 0
        categoryName = dict["categoryName"] as? String ?? ""
        addedDate = dict["addedDate"] as? String ?? ""
    }
    
    // To Dictionary
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        if let id = id {
            dict["id"] = id
        }
        if let categoryName = categoryName {
            dict["categoryName"] = categoryName
        }
        if let addedDate = addedDate {
            dict["addedDate"] = addedDate
        }
        return dict
    }
}
