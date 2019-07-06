//
//  user.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 5/4/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import Foundation

struct user{
    var userName : String?
    var profilePictureUrl : String?
    var email : String?
    var key : String?
    init(user : [String : AnyObject], key : String) {
        userName = user["userName"] as! String
        email = user["email"] as! String
        profilePictureUrl = user["profilePicture"] as! String
        self.key = key
    }
}
