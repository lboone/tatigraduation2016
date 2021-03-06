//
//  FeedVC.swift
//  tatigraduation2016
//
//  Created by Lloyd Boone on 3/14/16.
//  Copyright © 2016 LAMB Apps. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    @IBOutlet weak var postingView: UIView!
    
    @IBOutlet weak var dialogBkgView: UIView!
    
    
    var posts = [Post]()
    
    var imagePicker: UIImagePickerController!
    var imageChanged = false
    
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 423
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.cameraDialogDisplay(true, hide: true)
        self.postingDialogDisplay(true, hide: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("-------------------- OMG - RECEIVED MEMORY WARNING -----------------------")
        FeedVC.imageCache.removeAllObjects()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let post = posts[indexPath.row]
        //print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            /*
            if let url = post.imageUrl {
                print("Row: \(indexPath.row)")
                print(post.imageUrl)
                print(post.postDescription)
                print("Has Image")
                
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
                
                if img != nil {
                    print("Image found in cache")
                    
                } else {
                    print("Image NOT found in cache")
                }
                
            } else {
                print("Row: \(indexPath.row)")
                print(post.imageUrl)
                print(post.postDescription)
                print("No Image")
            }
            */
            cell.configureCell(post,img: img)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]

        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        if let imgType = info[UIImagePickerControllerMediaType] as? String {
            if imgType == "public.image" {
                if let img = info[UIImagePickerControllerOriginalImage] as? UIImage{
                    imageSelectorImage.image = img
                    imageChanged = true
                }
            } /*else {
                print("Not an image")
            }*/
        }
        
    }
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        self.cameraDialogDisplay(true, hide: false)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
            animated: true,
            completion: nil)
    }
    
    @IBAction func selectImageCameraPressed(sender: UIButton) {
        cameraDialogDisplay(true, hide: true)
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    @IBAction func selectImaeLibraryPressed(sender: UIButton) {
        cameraDialogDisplay(true, hide: true)
        if UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary) != nil {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    @IBAction func makePost(sender: MaterialButton) {
     
        if let txt = postField.text where txt != "" {
            postingDialogDisplay(true, hide: false)
            if let img = imageSelectorImage.image where imageChanged == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                
                //Put all informtion into data format
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = KEY_IMAGE_SHACK.dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
               
                
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                }) { encodingResult in
                    
                    switch encodingResult {
                        case .Success(let upload, _, _):

                            upload.responseJSON(completionHandler: { result in
                                if let info = result.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            //print("LINK: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            self.postingDialogDisplay(true, hide: true)
                            self.showErrorAlert("Error!", msg: "\(error)")
                    }
                }
                
            } else {
                self.postToFirebase(nil)
            }
        } else {
            postingDialogDisplay(true, hide: true)
            showErrorAlert("Message required!", msg: "Please provide a message before you post!")
        }
        
        
    }
    
    func postToFirebase(imgUrl: String?){
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0
        ]
        if imgUrl != nil {
            post["imageurl"] = imgUrl!
        }
        DataService.ds.createFirebasePost(post)
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageChanged = false
        postingDialogDisplay(true, hide: true)
        tableView.reloadData()
    }

    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func cameraDialogDisplay(animated: Bool, hide: Bool) {
        var dlgRect: CGRect
        var dlgAlpha: CGFloat
        let dlgHide = hide
        
        if hide == true {
            dlgRect = CGRectMake(0,-1800, view.frame.width, view.frame.height)
            dlgAlpha = 0.0
        } else {
            dlgRect = CGRectMake(0, 0, view.frame.width, view.frame.height)
            dlgAlpha = 1.0
        }
        
        if animated == true {
            UIView.animateWithDuration(0.50) {
                self.dialogBkgView.alpha = dlgAlpha
                self.dialogBkgView.hidden = dlgHide
                self.dialogBkgView.frame = dlgRect
                self.dialogBkgView.setNeedsDisplay()
            }
        } else {
            dialogBkgView.alpha = dlgAlpha
            dialogBkgView.hidden = dlgHide
            dialogBkgView.frame = dlgRect
            self.dialogBkgView.setNeedsDisplay()
        }

    }
    
    func postingDialogDisplay(animated: Bool, hide: Bool){
        var dlgRect: CGRect
        var dlgAlpha: CGFloat
        let dlgHide = hide
        
        if hide == true {
            dlgRect = CGRectMake(0, -63, self.view.layer.frame.width, self.postingView.layer.frame.height)
            dlgAlpha = 0.0
        } else {
            dlgRect = CGRectMake(0, -0, self.view.layer.frame.width, self.postingView.layer.frame.height)
            dlgAlpha = 1.0
        }
        
        if animated == true {
            UIView.animateWithDuration(0.50) {
                self.postingView.alpha = dlgAlpha
                self.postingView.hidden = dlgHide
                self.postingView.frame = dlgRect
            }
        } else {
            postingView.alpha = dlgAlpha
            postingView.hidden = dlgHide
            postingView.frame = dlgRect
        }
    }
}
