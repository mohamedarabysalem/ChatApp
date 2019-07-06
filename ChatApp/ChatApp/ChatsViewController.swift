//
//  CahtsViewController.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 5/4/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit
import CoreData
class ChatsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var users = [User]()
    var chatsId = [String]()
    var uid : String?
    var name : String?
    var chatId : String?
    var userName : String?
    var user1 : User1?
    let activityIndecator = UIActivityIndicatorView()
    let appDelegate = AppDelegate()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        appDelegate.checkIfFirstLunched()
        self.getUserData()
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatsTableViewCell
        let user = users[indexPath.row]
        cell.imageView?.image = UIImage(data: user.imageData!)
        cell.profilePicture!.layer.cornerRadius = cell.profilePicture!.frame.size.width / 2
        cell.profilePicture!.clipsToBounds = true
        cell.usserNameLabel.text = user.name!
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        name = user.name
        chatId = user.chatId
        print(chatId)
        performSegue(withIdentifier: "goToChat", sender: user)
    }
    func fetchTheCurrentUser(){
        let fetchRequest : NSFetchRequest<User1> = User1.fetchRequest()
        let predicate = NSPredicate(format: "uid == %@", uid! )
        fetchRequest.predicate = predicate
        if let user1 = (try! DataController.shared.viewContext.fetch(fetchRequest) as! [User1]).first{
            self.user1 = user1
            if (self.user1?.users?.count)! <= 0 {
                self.getChatsFromFireBase()
            }else{
                self.fetchData()
            }
            
        }else {
            let user1 = User1(context: DataController.shared.viewContext)
            user1.name = userName
            user1.uid = uid
            self.user1 = user1
            FirebaseApi.shared.user1 = user1
            if (self.user1?.users?.count)! <= 0 {
                self.getChatsFromFireBase()
            }else{
                self.fetchData()
            }
            try? DataController.shared.viewContext.save()
        }
        print(user1)
   
    }
    func fetchData(){
        print("fetch")
        let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "user1 == %@", user1!)
        fetchRequest.predicate = predicate
        users = try! DataController.shared.viewContext.fetch(fetchRequest)
        print(users.count)
        tableView.reloadData()
    }
    func getChatsFromFireBase(){
        activityIndicator()
        FirebaseApi.shared.getAllChats { (user, chatsId) in
            self.activityIndecator.stopAnimating()
            print("Download")
            if UserDefaults.standard.bool(forKey: "hasLunchedBefore") {
                for user in self.users{
                    if user != user{
                        self.users.append(user)
                    }
                }

            }else{
                self.users.append(user!)
                
            }
            
            
            print(user)

            self.tableView.reloadData()
        }
    }
    func getUserData(){
        FirebaseApi.shared.userData { (uid, name) in
            self.uid = uid
            self.userName = name
            self.fetchTheCurrentUser()
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {
            guard let user = sender as? User else {
                return
            }
            let vc = segue.destination as! ChatViewController
            vc.sender = uid
            vc.userName = userName
            vc.user = user
        }
    }
    @IBAction func newChatButton(_ sender: Any) {
        performSegue(withIdentifier: "goToNewChat", sender: self)
    }
    @IBAction func logoutButton(_ sender: Any) {
        FirebaseApi.shared.signout()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func refreshButton(_ sender: Any) {
        FirebaseApi.shared.user1 = user1
        getChatsFromFireBase()
    }
    func activityIndicator (){
        activityIndecator.style = UIActivityIndicatorView.Style.gray
        activityIndecator.center = self.view.center
        activityIndecator.hidesWhenStopped = true
        activityIndecator.startAnimating()
        self.view.addSubview(activityIndecator)
        activityIndecator.startAnimating()
    }
}
