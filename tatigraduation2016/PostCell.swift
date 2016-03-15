//
//  PostCell.swift
//  tatigraduation2016
//
//  Created by Lloyd Boone on 3/14/16.
//  Copyright © 2016 LAMB Apps. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    
    var post: Post!
    var request: Request?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        self.descriptionText.text = post.postDescription
        self.likeLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            } else {
                print("Configure Cell: img == nil")
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        if let img = UIImage(data: data!){
                            self.showcaseImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        }

                    }
                })
            }
        } else {
            self.showcaseImg.hidden = true
        }
    }

}
