//
//  DBManager.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 17/05/21.
//

import UIKit
import SQLite3

let DATABASE_NAME = "Notes.db"

let CATEGORIES_TABLE = "Categories"
let NOTES_TABLE = "Notes"

var BASE_PATH = ""

class DBManager: NSObject {
    
    //MARK:- Shared Instance
    static let shared = DBManager()
    private override init() { }
    
    //MARK:- Variables
    var db: OpaquePointer?
    
    //MARK:- Save file to the Directory
    func saveImageDocumentDirectory(_ image:UIImage,_ imgName:String) -> String?{
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imgName)")
        let imageData = image.jpegData(compressionQuality: 1.0)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return paths
    }
    
    //MARK:- Create Table
    func createTable(_ tblName:String) {
        // make sqlite database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(DATABASE_NAME)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        print(fileURL)
        BASE_PATH = fileURL.absoluteString.replacingOccurrences(of: DATABASE_NAME, with: "").replacingOccurrences(of: "file://", with: "")
        
        var query = ""
        if tblName == CATEGORIES_TABLE {
            query = "CREATE TABLE IF NOT EXISTS \(tblName) (id INTEGER PRIMARY KEY AUTOINCREMENT, categoryName TEXT, addedDate TEXT)"
        } else {
            query = "CREATE TABLE IF NOT EXISTS \(tblName) (id INTEGER PRIMARY KEY AUTOINCREMENT, catId TEXT, title TEXT, description TEXT, addedOn TEXT, latitude TEXT, longitute TEXT, images Text)"
        }
        
        if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    //MARK:- Insert Value in DataBase
    func insertSingleValue(_ tblName:String,_ dataModel:Any, _ completion: (_ :Bool) -> Void) {
        // Creating a statement
        var stmt: OpaquePointer?
        var queryString = ""
        if let model = dataModel as? CategoryDetailsModel {
            queryString = "INSERT INTO \(tblName) (categoryName , addedDate) VALUES ('\(model.categoryName ?? "")','\(model.addedDate ?? "")')"
        } else if let model = dataModel as? NotesDetailsModel {
            queryString = "INSERT INTO \(tblName) (catId, title , description, addedOn, latitude, longitute, images) VALUES ('\(model.catId ?? "")','\(model.title ?? "")','\(model.description ?? "")','\(model.addedOn ?? "")','\(model.latitude ?? "")','\(model.longitute ?? "")','\(model.images ?? "")')"
        }
        
        // The insert query
        
        
        // Preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            completion(false)
            return
        }
        
        // Executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting : \(errmsg)")
            completion(false)
            return
        }
        print("Data Save Successfully.")
        completion(true)
    }
    
    func readData(_ categoryId:Int?, _ tblName:String) -> [Any]? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(DATABASE_NAME)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //this is our select query
        var queryString = "SELECT * FROM \(tblName)"
        if categoryId != nil {
            queryString = "SELECT * FROM \(tblName) where catId = \(String(describing: categoryId ?? 0))"
        }
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        var arrayData = [Any]()
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            if tblName == CATEGORIES_TABLE {
                let id = Int(sqlite3_column_int(stmt, 0))
                let categoryName =  String(cString: sqlite3_column_text(stmt, 1))
                let addedDate =  String(cString: sqlite3_column_text(stmt, 2))
                let dict:[String: Any] = [
                    "id": id,
                    "categoryName": categoryName,
                    "addedDate": addedDate
                ]
                let model = CategoryDetailsModel(dict)
                arrayData.append(model)
            } else {
                let id = Int(sqlite3_column_int(stmt, 0))
                let catId = String(cString: sqlite3_column_text(stmt, 1))
                let title =  String(cString: sqlite3_column_text(stmt, 2))
                let description =  String(cString: sqlite3_column_text(stmt, 3))
                let addedOn = String(cString: sqlite3_column_text(stmt, 4))
                let latitude =  String(cString: sqlite3_column_text(stmt, 5))
                let longitute =  String(cString: sqlite3_column_text(stmt, 6))
                let images =  String(cString: sqlite3_column_text(stmt, 7))
                let dict:[String: Any] = [
                    "id": id,
                    "catId": catId,
                    "title": title,
                    "description": description,
                    "addedOn": addedOn,
                    "latitude": latitude,
                    "longitute": longitute,
                    "images":images
                ]
                let model = NotesDetailsModel(dict)
                arrayData.append(model)
            }
        }
        return arrayData
    }
    
    func removeImage(_ imgName: String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName)
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        } else {
            print("Something wrong")
        }
    }
    
    func removeOnlyRow(_ tblName: String, _ notesId:Int) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(DATABASE_NAME)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        var stmt: OpaquePointer?
        let queryStirng = "DELETE FROM \(tblName) WHERE id = '\(notesId)'"
        
        if sqlite3_prepare_v2(db, queryStirng, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(notesId))
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        //sqlite3_finalize(stmt)
    }
//
//    
////    func removeImage(_ imgName: String,_ picId:Int,_ tblName:String = ALL_IMAGES_TABLE) {
////        let fileManager = FileManager.default
////        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false)[0] as NSString).appendingPathComponent(imgName)
////        if fileManager.fileExists(atPath: paths){
////            try! fileManager.removeItem(atPath: paths)
////
////            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(DATABASE_NAME)
////
////            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
////                print("error opening database")
////            }
////
////            var stmt: OpaquePointer?
////            let queryStirng = "DELETE FROM \(tblName) WHERE picId = ?"
////
////            if sqlite3_prepare_v2(db, queryStirng, -1, &stmt, nil) == SQLITE_OK {
////                sqlite3_bind_int(stmt, 1, Int32(picId))
////                if sqlite3_step(stmt) == SQLITE_DONE {
////                    print("Successfully deleted row.")
////                } else {
////                    print("Could not delete row.")
////                }
////            } else {
////                print("DELETE statement could not be prepared")
////            }
////          sqlite3_finalize(stmt)
////        } else {
////            print("Something wrong")
////        }
////    }
    
    func updateParticularRow(_ id: Int, _ model: NotesDetailsModel, _ completion: (_ : Bool) -> Void) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(DATABASE_NAME)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return
        }
//        catId, title , description, addedOn, latitude, longitute, images
        let queryString = "UPDATE \(NOTES_TABLE) SET catId = '\(model.catId ?? "")', title = '\(model.title ?? "")', description = '\(model.description ?? "")', addedOn = '\(model.addedOn ?? "")', latitude = '\(model.latitude ?? "")', longitute = '\(model.longitute ?? "")', images = '\(model.images ?? "")' WHERE id='\(id)'"
        print(queryString)
        //statement pointer
        var stmt:OpaquePointer?
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            completion(false)
        }
        
        // Executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting : \(errmsg)")
            completion(false)
        }
        sqlite3_finalize(stmt)
        sqlite3_close(db)
        print("Data Save Successfully.")
        completion(true)
    }
}
