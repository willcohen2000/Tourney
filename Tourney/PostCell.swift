//
//  PostCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper
import AVKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postVideo: UIView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var viewed: Bool = false;
    
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!

    override func awakeFromNib() {
        super.awakeFromNib()
        userImg.layer.cornerRadius = userImg.frame.height / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avPlayerLayer.frame = postVideo.layer.bounds
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isUnactive() {
        player.pause();
    }
    
    func isActive() {
        player.play();
        if (!viewed) {
            updateViewsInDatabase(like: true)
            viewed = true
        }
        
    }
    
    func configCell(post: Post, img: UIImage? = nil, userImg: UIImage? = nil){
        //let playerItem = CachingPlayerItem(url: URL(string: link)!)
       // player = AVPlayer(playerItem: playerItem)
        player = AVPlayer(url: URL(string: post.videoLink)!)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.automaticallyWaitsToMinimizeStalling = false
        postVideo.layer.addSublayer(avPlayerLayer)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        
        postVideo.backgroundColor = UIColor.black
        self.post = post
        self.likesLbl.text = "\(post.views)"
        self.username.text = post.username
   
        
        /*if img != nil {
            self.postImg.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.postImg)
            ref.getData(maxSize: 100000000, completion: { (data, error) in
                if error != nil{
                    print("couldn't load image")
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData){
                            self.postImg.image = img
                        }
                    }
                }
            })
        }
        
        if userImg != nil {
            self.postImg.image = userImg
        } else {
            let ref = Storage.storage().reference(forURL: post.userImg)
            ref.getData(maxSize: 100000000, completion: { (data, error) in
                if error != nil{
                    print("couldn't load image")
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData){
                            self.userImg.image = img
                        }
                    }
                }
            })
        }*/
        
    }
    
    func updateViewsInDatabase(like: Bool) {
        let postRef = Database.database().reference().child("posts").child(post.postKey).child("views")
        if (like) {
            postRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                
                var currentCount = currentData.value as? Int ?? 0
                currentCount += 1
                currentData.value = currentCount
                
                return TransactionResult.success(withValue: currentData)
            })
        } else {
            postRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                
                var currentCount = currentData.value as? Int ?? 0
                currentCount -= 1
                currentData.value = currentCount
                
                return TransactionResult.success(withValue: currentData)
            })
        }
    }
    
    func updateLikesInUI(like: Bool) {
        let views = likesLbl.text!
        likesLbl.text = "\((Int(views)! + 1))"
    }
    
   /* @IBAction func liked(_ sender: AnyObject ){
        let likeRef = Database.database().reference().child("likes").child(currentUser!).child(post.postKey)
        
        likeRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.updateLikesInUI(like: true)
                self.updateViewsInDatabase(like: true)
                likeRef.child(self.post.postKey).setValue(true)
            } else {
                self.updateLikesInUI(like: false)
                self.updateViewsInDatabase(like: false)
                likeRef.child(self.post.postKey).removeValue()
            }
        })
    }*/

}
