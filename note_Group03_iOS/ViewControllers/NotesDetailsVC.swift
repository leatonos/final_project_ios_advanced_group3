//
//  NotesDetailsVC.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 17/05/21.
//

import UIKit
import MapKit

class NotesDetailsVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var collectionVw: UICollectionView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var mapVw: MKMapView!
    
    var notesDetail: NotesDetailsModel!
    var arrayImages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = notesDetail!.title
        arrayImages = notesDetail.images == "" ? [] : notesDetail.images.components(separatedBy: ",")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let dateStr = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(notesDetail.addedOn)!)))
        lblDate.text = dateStr
        
        collectionVw.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        collectionVw.reloadData()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(notesDetail.latitude) ?? 0.00, longitude: Double(notesDetail.longitute) ?? 0.00)
        mapVw.addAnnotation(annotation)
        
        let center = annotation.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapVw.setRegion(region, animated: true)
        
        lblDescription.text = notesDetail.description

        // Do any additional setup after loading the view.
    }
    
    // Delete Action
    @IBAction func btnActnDelete(_ sender: Any) {
        AlertControl.shared.showAlert("Alert!", message: "Do you want to delete this note?", buttons: ["Yes", "No"]) { index in
            if index == 0 {
                for i in 0..<self.arrayImages.count {
                    FileSaveManager.shared.removeImage(self.arrayImages[i])
                }
                CoreDataManager.shared.delete(NOTES_ENTITY, self.notesDetail.id) { success in
                    if success {
                        AlertControl.shared.showAlert("Success", message: "You have successfully deleted the note", buttons: ["Ok"]) { index in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        
    }
    
    // Edit Action
    @IBAction func btnActnEdit(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddNotesVC") as! AddNotesVC
        vc.notesDetail = notesDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotesDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        DispatchQueue.main.async {
            print(BASE_PATH +  self.arrayImages[indexPath.row])
            if FileManager.default.fileExists(atPath: BASE_PATH +  self.arrayImages[indexPath.row]) {
                cell.imgVw.image = UIImage(contentsOfFile: BASE_PATH + self.arrayImages[indexPath.row].replacingOccurrences(of: ",", with: ""))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

