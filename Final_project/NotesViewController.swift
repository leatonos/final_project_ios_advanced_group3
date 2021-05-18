//
//  NotesViewController.swift
//  Final_project
//
//  Created by user198868 on 5/18/21.
//

import UIKit

class NotesViewController: UIViewController {
    
    struct note {
            var title: String
            var date: String
            var text: String
    }
    
    let diaryNotes = [
        note(title: "Lucky day", date: "16/02/2021", text: "Testing"),
        note(title: "First day at work", date: "18/01/2021", text: "It was hard"),
        note(title: "Hard day at school", date: "08/04/2021", text: "Don`t know")
    ]
    
    @IBOutlet weak var notesTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        notesTableView.delegate = self
        notesTableView.dataSource = self
        
    }

}

extension NotesViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "readNote", sender: nil)
    }
    
}

extension NotesViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        
        cell.textLabel?.text = diaryNotes[indexPath.row].title + "\n" + diaryNotes[indexPath.row].date
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .white
        
        
        return cell
    }
    
}
