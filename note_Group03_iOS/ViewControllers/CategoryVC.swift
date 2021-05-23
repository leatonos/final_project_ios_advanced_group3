//
//  CategoryVC.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 13/05/21.
//

import UIKit

class CategoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblVwCategory: UITableView!
    
    var arrayCategory = [CategoryDetailsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBManager.shared.createTable(CATEGORIES_TABLE)
        arrayCategory = DBManager.shared.readData(nil, CATEGORIES_TABLE) as! [CategoryDetailsModel]
        tblVwCategory.reloadData()
        
        self.navigationItem.title = "Categories"
        
        tblVwCategory.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addCategory(_:)))

        // Do any additional setup after loading the view.
    }
    
    @objc func addCategory(_ sender: UIBarButtonItem) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField!.text))")
            if textField!.text != "" {
                let dict:[String: Any] = [
                    "categoryName": textField!.text!,
                    "addedDate": Date().timeIntervalSince1970.description
                ]
                DBManager.shared.createTable(CATEGORIES_TABLE)
                DBManager.shared.insertSingleValue(CATEGORIES_TABLE, CategoryDetailsModel(dict)) { success in
                    if success {
                        AlertControl.shared.showAlert("Success", message: "Your data saved successfully", buttons: ["Ok"], completion: nil)
                    }
                }
                self.arrayCategory = DBManager.shared.readData(nil, CATEGORIES_TABLE) as! [CategoryDetailsModel]
                self.tblVwCategory.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        cell.lblCategory.text = arrayCategory[indexPath.row].categoryName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "NotesVC") as! NotesVC
        vc.catId = arrayCategory[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
