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
import Kingfisher

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
        self.avPlayerLayer.frame = self.postVideo.layer.bounds
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isUnactive() {
        if let player = player {
            player.pause();
        }
        
    }
    
    func isActive() {
        if let player = player {
            player.play();
        }
        
    }
    
    func configCell(post: Post, img: UIImage? = nil, userImg: UIImage? = nil) {
        
        self.player = AVPlayer(playerItem: AVPlayerItem(asset: post.downloadedAsset))
        self.avPlayerLayer = AVPlayerLayer(player: self.player)
        self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.player.automaticallyWaitsToMinimizeStalling = false
        self.postVideo.layer.addSublayer(self.avPlayerLayer)
        self.player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        
        postVideo.backgroundColor = UIColor.black
        self.post = post
        self.likesLbl.text = "\(post.views)"
        self.username.text = post.username
   
        self.userImg.kf.setImage(with: URL(string: post.userImg))
        
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
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("button")
        
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
