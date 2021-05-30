//
//  CameraHandler.swift
//  note_Group03_iOS
//
//  Created by Jaspinder Singh on 17/05/21.
//

import UIKit

class CameraHandler: NSObject , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static let shared = CameraHandler()
    var picker = UIImagePickerController()
//    var alert: UIAlertController
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?
    
    override init(){
        super.init()
    }
    
    // Image Pick Function
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        pickImageCallback = callback;
        self.viewController = viewController;
        
//        let cameraAction = UIAlertAction(title: "Camera", style: .default){
//            UIAlertAction in
//            self.openCamera()
//        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
       // alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    
//    func openCamera(){
//       // alert.dismiss(animated: true, completion: nil)
//        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
//            picker.sourceType = .camera
//            self.viewController!.present(picker, animated: true, completion: nil)
//        } else {
//            AlertControl.shared.showAlert("", message: "You don't have camera", buttons: ["Ok"], completion: nil)
//        }
//    }
    
    // Open Gallery
    func openGallery(){
       // alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        pickImageCallback?(image)
        
    }

    //  // For Swift 4.2
    //  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //      picker.dismiss(animated: true, completion: nil)
    //      guard let image = info[.originalImage] as? UIImage else {
    //          fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    //      }
    //      pickImageCallback?(image)
    //  }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
    }
    
}

//MARK: How to use

/*
 Info.Plist
 <key>NSCameraUsageDescription</key>
 <string></string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string></string>

 Use In Class
 CameraHandler.shared.pickImage(self) { (image) in
    print(image)
 }
  */
