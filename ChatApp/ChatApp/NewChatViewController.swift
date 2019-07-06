//
//  NewChatViewController.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 5/4/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit

class NewChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    var users = [user]()
    let activityIndecator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getAllUser()
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newChatCell", for: indexPath) as! NewChatTableCell
        let user = users[indexPath.row]
        cell.userNameLabel.text = user.userName
        let url = URL(string: user.profilePictureUrl!)
        let imageData = try? Data(contentsOf: url!)
        cell.profilePicture.image = UIImage(data: imageData!)
        cell.profilePicture!.layer.cornerRadius = cell.profilePicture!.frame.size.width / 2
        cell.profilePicture!.clipsToBounds = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator()
        let user = users[indexPath.row]
        print(user.key!)
        let user1 = User(context: DataController.shared.viewContext)
        user1.name = user.userName
        let url = URL(string: user.profilePictureUrl!)
        let imageData = try! Data(contentsOf: url!)
        user1.imageData = imageData
        user1.uid = user.key
        try! DataController.shared.viewContext.save()
        FirebaseApi.shared.addNewChat(key: user.key!) { (chatId) in
            user1.chatId = chatId
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.activityIndecator.stopAnimating()
            self.performSegue(withIdentifier: "goToChat", sender: user1)

        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat"{
            guard let user = sender as? User else {
                return
            }
            FirebaseApi.shared.userData { (uid, userName) in
                let vc = segue.destination as! ChatViewController
                vc.user = user
                vc.sender = uid
                vc.userName = userName
                print(user)
                print(userName)
                print(uid)
            }
           
        }
    }
    
    func getAllUser(){
        activityIndicator()
        FirebaseApi.shared.getAllUsers { (result) in
            self.activityIndecator.stopAnimating()
            self.users = result
            self.tableView.reloadData()
        }
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
