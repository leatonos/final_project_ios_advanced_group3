//
//  CoreDataManager.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 27/05/21.
//

import UIKit
import CoreData

let CATEGORY_ENTITY = "Category"

let NOTES_ENTITY = "Notes"

class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    
    private override init() {}
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getContext() -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    // Get Data
    func getData(_ entity: String, _ catId: String = "0") -> [Any] {
        let query = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if catId != "0" {
            query.predicate = NSPredicate.init(format: "catId==\(catId)")
        }
        
        query.returnsObjectsAsFaults = false;
        
        do {
            let results = try getContext().fetch(query)
            
            print("Rows found in db: " , results.count)
            
            var arrayData = [Any]()
            for i in 0..<results.count {
                print(results[i])
                let dataVal = results[i] as! NSManagedObject
                if entity == CATEGORY_ENTITY {
                    var model = CategoryDetailsModel([:])
                    model.id = dataVal.value(forKey: "id") as? Int ?? 0
                    model.categoryName = dataVal.value(forKey: "categoryName") as? String ?? ""
                    model.addedDate = dataVal.value(forKey: "addedDate") as? String ?? ""
                    arrayData.append(model)
                } else {
                    var model = NotesDetailsModel([:])
                    model.id = dataVal.value(forKey: "id") as? Int ?? 0
                    model.catId = dataVal.value(forKey: "catId") as? String ?? ""
                    model.title = dataVal.value(forKey: "title") as? String ?? ""
                    model.description = dataVal.value(forKey: "desc") as? String ?? ""
                    model.addedOn = dataVal.value(forKey: "addedOn") as? String ?? ""
                    model.latitude = dataVal.value(forKey: "latitude") as? String ?? ""
                    model.longitute = dataVal.value(forKey: "longitute") as? String ?? ""
                    model.baseUrl = dataVal.value(forKey: "baseUrl") as? String ?? ""
                    model.images = dataVal.value(forKey: "images") as? String ?? ""
                    arrayData.append(model)
                }
            }
            return arrayData
        }
        catch {
            print("Some error occured when fetching the data!!")
            return []
        }
    }
    
    
    // Insert Data
    func insertData(_ entity: String, _ dataValue: [String: Any], _ completion: (_ : Bool) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Sort Descriptor
        let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [idDescriptor] // Note this is a array, you can put multiple sort conditions if you want
        
        // Set limit
        fetchRequest.fetchLimit = 1
        
        var newId = 0; // Default to 0, so that you can check if do catch block went wrong later
        
        do {
            let results = try getContext().fetch(fetchRequest)
            
            //Compute the id
            if(results.count == 1){
                let id = (results[0] as! NSManagedObject).value(forKey: "id") as? Int32 ?? 0
                newId = Int(id) + 1
            } else {
                newId = 1
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        let rowObj = NSEntityDescription.insertNewObject(forEntityName: entity, into: getContext())
        var dict = dataValue
        dict["id"] = newId
        for (key, value) in dict {
            print("\(key) -> \(value)")
            rowObj.setValue(value, forKey: key)
        }
        do{
            try getContext().save()
            print("Saved")
            completion(true)
        }catch{
            print("Error")
            completion(false)
        }
    }
    
    
    // Update Data
    func updateData(_ entity: String, _ id: Int, _ dict: [String: Any], _ completion: (_ : Bool) -> Void) {
        let query = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
       // query.predicate = NSPredicate(format: "productId = %@", productDetail.productId)
        query.predicate = NSPredicate.init(format: "id==\(id)")
        query.returnsObjectsAsFaults = false
        
        do {
            let result = try getContext().fetch(query)
            for object in result {
                let dataModel = object as! NSManagedObject
                for (key, value) in dict {
                    print("\(key) -> \(value)")
                    dataModel.setValue(value, forKey: key)
                }
            }
            try getContext().save()
            
            completion(true)
        } catch {
            print("Some error occured when fetching the data!!")
            completion(false)
        }
    }
    
    // Delete Function
    func delete(_ entity: String, _ id: Int, _ completion: (_ : Bool) -> Void) {
        let query = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        // query.predicate = NSPredicate(format: "productId = %@", productDetail.productId)
        query.predicate = NSPredicate.init(format: "id==\(id)")
        query.returnsObjectsAsFaults = false
        
        do {
            let result = try getContext().fetch(query)
            for object in result {
                getContext().delete(object as! NSManagedObject)
            }
            try getContext().save()
            completion(true)
        } catch {
            print("Some error occured when fetching the data!!")
            completion(false)
        }
    }
    
}
