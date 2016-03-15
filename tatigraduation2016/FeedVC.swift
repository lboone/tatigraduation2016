//
//  FeedVC.swift
//  tatigraduation2016
//
//  Created by Lloyd Boone on 3/14/16.
//  Copyright © 2016 LAMB Apps. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    
    var posts = [Post]()
    
    var imagePicker: UIImagePickerController!
    
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
        //print(info)
        //print(info[UIImagePickerControllerMediaType])
        //print(info[UIImagePickerControllerOriginalImage])
        if let imgType = info[UIImagePickerControllerMediaType] as? String {
            if imgType == "public.image" {
                if let img = info[UIImagePickerControllerOriginalImage] as? UIImage{
                    imageSelectorImage.image = img
                }
            } else {
                print("Not an image")
            }
        }
        
    }
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func makePost(sender: MaterialButton) {
        
    }

    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
