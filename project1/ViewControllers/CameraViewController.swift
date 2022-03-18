//
//  CameraViewController.swift
//  project1
//
//  Created by فاطمه المطر on 14/06/2021.
//

import UIKit
import AVFoundation   //give us tools to allow as manipulate with audio & video

class CameraViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textViewOutlet: UITextView!
    @IBOutlet weak var postImgOutlet: UIImageView!
    @IBOutlet weak var shareBtnOutlet: UIBarButtonItem!
    
    // Type followed by ? to indicate that this is optional so user may choose img or video
    var userSelectImageToStorage : UIImage?
    var userSelectVideoToStorage : URL?
    
    var placeHolderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handelPlaceHolder()
        handelShareBtn()
        
        let postImgGesture = UITapGestureRecognizer(target: self, action:#selector(pickPostImg))
        postImgOutlet.addGestureRecognizer(postImgGesture)
        postImgOutlet.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        textViewOutlet.text = ""
        userSelectImageToStorage = nil
        postImgOutlet.image = UIImage(systemName: "photo.on.rectangle.angled")
    }
    
    @IBAction func sharePostBtn(_ sender: Any) {
        if let postImage = self.userSelectImageToStorage , let postIMG = postImage.jpegData(compressionQuality: 0.1) {
            let imageSize = postImage.size.width / postImage.size.height
            Authentication.SharePost(videoURL : userSelectVideoToStorage, imageData: postIMG, caption: textViewOutlet.text!, imageSize: imageSize) {
                //if success
                self.tabBarController?.selectedIndex = 0
            } IfCameraVCError: { (error) in
                print(error)
            }


    }
    }
    
    
    @objc func pickPostImg(){
        print("user select img")
        //the following controller will allow us to go to studio and choose img
        let postImgPicker = UIImagePickerController()
        //to allow us to edit the img
        postImgPicker.allowsEditing = true
        postImgPicker.delegate = self
        // to allow adding media
        postImgPicker.mediaTypes = ["public.image" , "public.movie"]
        //to present the view of studio
        present(postImgPicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //note: this function is to check if the image is choosen or not , it its not we will not be able to share the post
    func handelShareBtn(){
        if postImgOutlet != nil {
            shareBtnOutlet.isEnabled = true
        }else{
            shareBtnOutlet.isEnabled = false
        }
    }
    
    func handelPlaceHolder() {
        textViewOutlet.delegate = self
        placeHolderLabel = UILabel()
        placeHolderLabel.text = "Add Image Caption...."
        placeHolderLabel.sizeToFit()
        textViewOutlet.addSubview(placeHolderLabel)
        placeHolderLabel.frame.origin = CGPoint(x: 5, y: (textViewOutlet.font?.pointSize)! / 2)
        placeHolderLabel.textColor = .lightGray
        textViewOutlet.textColor = .black
        placeHolderLabel.isHidden = !textViewOutlet.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = !textViewOutlet.text.isEmpty
    }
}

extension CameraViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //for video
        if let userSelectVideo = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let thumbImg = self.thumbnailImgForVideo(userSelectVideo) {
                postImgOutlet.image = thumbImg
                userSelectImageToStorage = thumbImg
                userSelectVideoToStorage = userSelectVideo
            }
        }
        
        //for images
        if let userSelectedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            postImgOutlet.image = userSelectedImg
            userSelectImageToStorage = userSelectedImg
            
        }
        dismiss(animated: true, completion: nil)
    }//end did finish picking media
    
    func thumbnailImgForVideo(_ file : URL) -> UIImage? {
        let asset = AVAsset(url: file)
        let imageGnerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailImg = try imageGnerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 10), actualTime: nil)
            return UIImage(cgImage: thumbnailImg)
        } catch let error {
            print(error.localizedDescription)
        }
        return UIImage()
    }
    
}
