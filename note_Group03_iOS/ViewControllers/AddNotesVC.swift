//
//  AddNotesVC.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 17/05/21.
//

import UIKit
import CoreLocation

class AddNotesVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var txtFldCategory: UITextField!
    @IBOutlet weak var txtFldTitle: UITextField!
    @IBOutlet weak var txtVwDescription: UITextView!
    @IBOutlet weak var constantCatTop: NSLayoutConstraint!
    @IBOutlet weak var collectionVwImages: UICollectionView!
    
    var catID = 0
    private var userLocation: CLLocationCoordinate2D?
    private var locationManager = CLLocationManager()
    var arrayImages = [String]()
    var notesDetail: NotesDetailsModel!
    var arrayCategory = [CategoryDetailsModel]()
    
    let pickerVwCat = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionVwImages.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        print(catID)
        
        if notesDetail == nil {
            constantCatTop.constant = -65
            lblCategory.isHidden = true
            txtFldCategory.isHidden = true
        } else {
            
            arrayCategory = CoreDataManager.shared.getData(CATEGORY_ENTITY) as! [CategoryDetailsModel]
            catID = Int(notesDetail.catId) ?? 0
            let selectedCat = arrayCategory.filter { first in
                return first.id == catID
            }
            
            if selectedCat.count > 0 {
                txtFldCategory.text = selectedCat[0].categoryName
            }
            
            pickerVwCat.dataSource = self
            pickerVwCat.delegate = self
            
            pickerVwCat.reloadAllComponents()
            
            txtFldCategory.inputView = pickerVwCat
            
            txtFldTitle.text = notesDetail.title
            txtVwDescription.text = notesDetail.description
            
            arrayImages = notesDetail.images == "" ? [] : notesDetail.images.components(separatedBy: ",")
            collectionVwImages.reloadData()
            
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        if let userLocation = locationManager.location?.coordinate {
            self.userLocation = userLocation
        }
        
        locationManager.startUpdatingLocation()
        
        self.navigationItem.title = notesDetail == nil ? "New Note" : "Edit Note"
        
        // constantCatTop.constant = -65
        
        txtVwDescription.layer.borderWidth = 1.0
        txtVwDescription.layer.borderColor = UIColor.gray.cgColor
        txtVwDescription.layer.cornerRadius = 5.0
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: notesDetail == nil ? "Save" : "Update", style: .plain, target: self, action: #selector(addNotes(_:)))
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0].coordinate
    }
    
    
    // Add Note
    @objc func addNotes(_ sender: UIBarButtonItem) {
        var willSave = false
        var strAlert = ""
        if txtFldTitle.text == "" {
            strAlert = "Please enter Title"
        } else if txtVwDescription.text == "" {
            strAlert = "Please enter description"
        } else {
            willSave = true
        }
        if !willSave {
            AlertControl.shared.showAlert("Alert!", message: strAlert, buttons: ["Ok"], completion: nil)
            return
        }
        if notesDetail != nil {
            let dict: [String: Any] = [
                "id": notesDetail.id ?? 0,
                "catId": catID.description,
                "title": txtFldTitle.text!,
                "desc": txtVwDescription.text!,
                "addedOn": Date().timeIntervalSince1970.description,
                "latitude": userLocation!.latitude.description,
                "longitute": userLocation!.longitude.description,
                "images": arrayImages.joined(separator: ",")
            ]
            
            CoreDataManager.shared.updateData(NOTES_ENTITY, notesDetail.id, dict) { success in
                if success {
                    AlertControl.shared.showAlert("Success!", message: "Your data updated successfully.", buttons: ["OK"]) { _ in
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: NotesVC.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                }
            }
        } else {
            let dict: [String: Any] = [
                "catId": catID.description,
                "title": txtFldTitle.text!,
                "desc": txtVwDescription.text!,
                "addedOn": Date().timeIntervalSince1970.description,
                "latitude": userLocation!.latitude.description,
                "longitute": userLocation!.longitude.description,
                "images": arrayImages.joined(separator: ",")
            ]
            CoreDataManager.shared.insertData(NOTES_ENTITY, dict) { success in
                if success {
                    AlertControl.shared.showAlert("Success!", message: "Your data saved successfully.", buttons: ["OK"]) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // Action Camera Button
    @IBAction func btnActnCamera(_ sender: Any) {
        CameraHandler.shared.pickImage(self) { image in
            let imageName = Int(Date().timeIntervalSince1970).description + ".png"
            _ = FileSaveManager.shared.saveImageDocumentDirectory(image, imageName)
            self.arrayImages.append(imageName)
            self.collectionVwImages.reloadData()
        }
    }
    @IBAction func btnActnAudio(_ sender: Any) {
        
    }
    
    
}

extension AddNotesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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


extension AddNotesVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayCategory[row].categoryName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtFldCategory.text = arrayCategory[row].categoryName
        catID = arrayCategory[row].id
    }
}
