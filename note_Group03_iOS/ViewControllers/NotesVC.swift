//
//  NotesVC.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 17/05/21.
//

import UIKit

class NotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblVwNotes: UITableView!
    @IBOutlet weak var txtFldSort: UITextField!
    
    var catId = 0
    var arrayNotes = [NotesDetailsModel]()
    var arrayAllNotes = [NotesDetailsModel]()
    let pickerVw = UIPickerView()
    let arraySort = ["Sort by Date", "Sort by Name"]
    var selectedSort = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFldSort.text = arraySort[selectedSort]
        
        pickerVw.dataSource = self
        pickerVw.delegate = self
        
        pickerVw.reloadAllComponents()
        
        txtFldSort.inputView = pickerVw
        
        print(catId)
        
        self.navigationItem.title = "Notes"
        
        tblVwNotes.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addNotes(_:)))
        
        DBManager.shared.createTable(NOTES_TABLE)
        arrayAllNotes = DBManager.shared.readData(catId, NOTES_TABLE) as! [NotesDetailsModel]

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arrayAllNotes = DBManager.shared.readData(catId, NOTES_TABLE) as! [NotesDetailsModel]
        arrayNotes = DBManager.shared.readData(catId, NOTES_TABLE) as! [NotesDetailsModel]
        tblVwNotes.reloadData()
        setDataAsPerSort()
    }
    
    @objc func addNotes(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddNotesVC") as! AddNotesVC
        vc.catID = catId
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        cell.imgVw.image = UIImage(systemName: "note")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let dateStr = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(arrayNotes[indexPath.row].addedOn)!)))
        cell.lblCategory.text = arrayNotes[indexPath.row].title + "\n" + dateStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "NotesDetailsVC") as! NotesDetailsVC
        vc.notesDetail = arrayNotes[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setDataAsPerSort() {
        txtFldSort.text = arraySort[selectedSort]
        if selectedSort == 0 {
            arrayAllNotes = arrayAllNotes.sorted(by: { first, second in
                return Double(first.addedOn)! < Double(second.addedOn)!
            })
        } else if selectedSort == 1 {
            arrayAllNotes = arrayAllNotes.sorted(by: { first, second in
                return first.title.lowercased() < second.title.lowercased()
            })
        }
        if searchBar.text == "" {
            arrayNotes = arrayAllNotes
        } else {
            arrayNotes = arrayAllNotes.filter({ first in
                return first.title.lowercased().contains(searchBar.text!.lowercased())
            })
        }
        tblVwNotes.reloadData()
    }

}

extension NotesVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            arrayNotes = arrayAllNotes
        } else {
            arrayNotes = arrayAllNotes.filter({ first in
                return first.title.lowercased().contains(searchText.lowercased())
            })
        }
        tblVwNotes.reloadData()
    }
}

extension NotesVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arraySort.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arraySort[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSort = row
        setDataAsPerSort()
    }
}
