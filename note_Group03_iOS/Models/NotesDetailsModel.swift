//
//  NotesDetailsModel.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 18/05/21.
//

import Foundation

struct NotesDetailsModel {
    var id: Int!
    var catId: String!
    var title: String!
    var description: String!
    var addedOn: String!
    var latitude: String!
    var longitute: String!
    var baseUrl: String!
    var images: String!

    init(_ dict:[String: Any]) {
        id = dict["id"] as? Int ?? 0
        catId = dict["catId"] as? String ?? "0"
        title = dict["title"] as? String ?? ""
        description = dict["description"] as? String ?? ""
        addedOn = dict["addedOn"] as? String ?? ""
        latitude = dict["latitude"] as? String ?? ""
        longitute = dict["longitute"] as? String ?? ""
        baseUrl = dict["baseUrl"] as? String ?? ""
        images = dict["images"] as? String ?? ""
    }
}
