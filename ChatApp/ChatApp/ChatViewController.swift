//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Mohamad El Araby on 5/4/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import CoreData
class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var messagees = [Message]()
    var sender : String?
    var userName : String?
    var user : User?
    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = sender
        senderDisplayName = userName
        title = user?.name
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        if user?.messages?.count != 0 {
            fetchMessages()
        }
        getMessagesFromFireBase()
        // Do any additional setup after loading the view.
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let message = Message(context: DataController.shared.viewContext)
        message.chat = user
        message.content = text
        message.name = senderDisplayName
        message.sender = senderId
        try? DataController.shared.viewContext.save()
        FirebaseApi.shared.saveMessage(chatId: (user?.chatId!)!, senderId: senderId, text:text , senderDisplayName: senderDisplayName)
        finishSendingMessage()
    }
    func getMessagesFromFireBase(){
        FirebaseApi.shared.getMessages(chatId: user?.chatId) { (id, name, text) in
            if let message = JSQMessage(senderId: id, displayName: name, text: text)
            {
                let messageee = Message(context: DataController.shared.viewContext)
                messageee.chat = self.user
                messageee.sender = id
                messageee.name = name
                messageee.content = text
                try? DataController.shared.viewContext.save()
                self.messages.append(message)
                self.finishReceivingMessage()
            }
        }
    }
    func fetchMessages (){
        print("fetch")
        let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chat == %@", argumentArray: [user])
        messagees = try! DataController.shared.viewContext.fetch(fetchRequest)
        for message in messagees {
            let mess = JSQMessage(senderId: message.sender, displayName: message.name, text: message.content)
            messages.append(mess!)
            collectionView.reloadData()
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
}
