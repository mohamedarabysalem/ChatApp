//
//  FirebaseAPI.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 4/27/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
class FirebaseApi {
    var uid : String?
    var name : String?
    var i = 0
    var user1 : User1?
    static let shared  = FirebaseApi()
    func login (email : String , password : String , completion : @escaping (_ succ : Bool , String?)-> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(false, error?.localizedDescription)
            }
            else {
                self.uid = user?.user.uid
                Database.database().reference().child("users").child(self.uid!).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    let userDict = DataSnapshot.value as! [String:AnyObject]
                    self.name = userDict["userName"] as! String
                    print(self.name)
                    print("Log in successful!")
                    completion(true,nil)
                })
                
                
            }
        }
    }
    func signup(email : String , password : String , profileImage : UIImage? , userName : String, completion : @escaping  (_ succ : Bool)->Void){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(false)
                print(error!)
            }else {
                 self.uid = user?.user.uid
                self.name = userName
                let storageRef = Storage.storage().reference(forURL: "gs://udacityproject-1841f.appspot.com").child("profile_image").child(self.uid!)
                if let image = profileImage , let imageData = image.jpegData(compressionQuality: 0.1){
                    storageRef.putData(imageData, metadata: nil, completion: { (meta, error) in
                        storageRef.downloadURL(completion: { (url, error) in
                            let profilePictureURL = url?.absoluteString
                            let newUser = ["userName" : userName ,
                                           "email" : email ,
                                           "profilePicture" : profilePictureURL ] as [String : Any]
                            print(profilePictureURL)
                            print(newUser)
                            Database.database().reference().child("users").child(self.uid!).setValue(newUser)
                            print("signup Successful!")
                            completion(true)
                        })
                       
                    })
                }
            }
        }
    }
    func signout(){
        try? Auth.auth().signOut()
    }
    func getAllChats(completion : @escaping(_ result : User? , _ chatIds : [String]?)-> Void){
        var keys = [String] ()
        var chatIds = [String] ()
        var users = [User]()
        print(name)
        Database.database().reference().child("userChats").child(uid!).observeSingleEvent(of: .value) { (DataSnapshot) in
            for child in DataSnapshot.children {
                let snap = child as! DataSnapshot
                let snapDict = snap.value as! [String : AnyObject]
                let chatId = snapDict["chatId"] as! String
                chatIds.append(chatId)
                keys.append(snap.key)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           
            for key in keys{
                print(key)
                Database.database().reference().child("users").child(key).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                   // print(DataSnapshot)
                    print(self.i)
                    let userDict = DataSnapshot.value as! [String : AnyObject]
                    let user = User(context: DataController.shared.viewContext)
                    let chatId = chatIds[self.i]
                    print(chatId)
                    user.chatId = chatId
                    user.name = userDict["userName"] as? String
                    let url = URL(string: userDict["profilePicture"] as! String)
                    user.imageData = try? Data(contentsOf: url!)
                    user.uid = DataSnapshot.key
                    user.user1 = self.user1
                    //self.user1.users = NSSet(object: users)
                    users.append(user)
                    print(user)
                    try? DataController.shared.viewContext.save()
                    self.i+=1
                    completion(user,chatIds)
                })
            }
        }
        

    }
    func getAllUsers(completion: @escaping (_ users : [user])-> Void){
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (DataSnapshot) in
            var users = [user]()
            for child in DataSnapshot.children{
                let snap = child as! DataSnapshot
                let userDict = snap.value as! [String : AnyObject]
                //print(snap)
                if snap.key != self.uid {
                    users.append(user(user: userDict, key : snap.key))
                }
            }
             completion(users)
        }
    }
    func addNewChat(key : String , completion : @escaping(String?)->Void){
        let newChat = ["name" : "",
                       "content" : "",
                       "sender" : ""]
        print(uid!)
        Database.database().reference().child("chats").childByAutoId().setValue(newChat)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Database.database().reference().child("chats").observeSingleEvent(of: .value, with: { (dataSnapShot) in
                var key1 : String?
                for child in dataSnapShot.children {
                    
                    let snap = child as! DataSnapshot
                    key1 = snap.key
                }
                print(key1)
                
                let newUserChat = ["chatId" : key1]
               Database.database().reference().child("userChats").child(self.uid!).child(key).setValue(newUserChat)
               Database.database().reference().child("userChats").child(key).child(self.uid!).setValue(newUserChat)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    completion(key1)
                })
            })
        }
    }
    func saveMessage(chatId : String , senderId : String , text : String , senderDisplayName : String){
        let ref = Database.database().reference().child("chats").child(chatId).childByAutoId()
        
        let message = ["sender": senderId, "name": senderDisplayName, "content": text]
        
        ref.setValue(message)

    }
    func getMessages(chatId:String?, completion:@escaping(_ id: String,_ name:String,_ text:String)->Void){
        let query = Database.database().reference().child("chats").child(chatId!).queryLimited(toLast: 4)
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender"],
                let name       = data["name"],
                let text        = data["content"],
                !text.isEmpty
            {
                completion(id,name,text)
            }
        })
    }
    func userData(completion:@escaping(_ uid:String,_ userName:String)->Void){
        completion(self.uid!,self.name!)
    }
    
}
