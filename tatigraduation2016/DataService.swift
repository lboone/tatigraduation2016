//
//  DataService.swift
//  tatigraduation2016
//
//  Created by Lloyd Boone on 3/12/16.
//  Copyright © 2016 LAMB Apps. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://tatigraduation2016.firebaseio.com"

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url:"\(URL_BASE)" )
    private var _REF_POSTS = Firebase(url:"\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url:"\(URL_BASE)/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        //print("CURRENT USER ID: \(uid)")
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser(uid: String, user:Dictionary<String, String>){
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    func createFirebasePost(post:Dictionary<String, AnyObject>) {
        let firebasePost = self.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
    }
}
