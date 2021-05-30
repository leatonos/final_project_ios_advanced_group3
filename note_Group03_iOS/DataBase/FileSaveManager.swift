//
//  FileSaveManager.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 17/05/21.
//

import UIKit

let DATABASE_NAME = "Notes.db"

let CATEGORIES_TABLE = "Categories"
let NOTES_TABLE = "Notes"

var BASE_PATH = ""

class FileSaveManager: NSObject {
    
    //MARK:- Shared Instance
    static let shared = FileSaveManager()
    private override init() { }
    
    //MARK:- Variables
    var db: OpaquePointer?
    
    func getBaseUrl() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        BASE_PATH = fileURL.absoluteString.replacingOccurrences(of: DATABASE_NAME, with: "").replacingOccurrences(of: "file://", with: "")
    }
    
    //MARK:- Save file to the Directory
    func saveImageDocumentDirectory(_ image:UIImage,_ imgName:String) -> String? {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imgName)")
        print(paths)
        let imageData = image.jpegData(compressionQuality: 1.0)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return paths
    }
    

    // Remove Image
    func removeImage(_ imgName: String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName)
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        } else {
            print("Something wrong")
        }
    }
    
}
