//
//  TopVideoController.swift
//  Tourney
//
//  Created by Will Cohen on 7/30/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit
import AVKit

class TopVideoController: UIViewController {

    @IBOutlet weak var previewVideoView: UIView!
    
    var post: Post!
    
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            avPlayerLayer.frame = previewVideoView.layer.bounds;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //player.play()
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        print("what hapepned dude: \(post.videoLink)")
       /* let playerItem = CachingPlayerItem(url: URL(string: post.videoLink)!)
        player = AVPlayer(playerItem: playerItem)
        avPlayerLayer = AVPlayerLayer(player: player);
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        player.automaticallyWaitsToMinimizeStalling = false
        previewVideoView.layer.addSublayer(avPlayerLayer);
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero);
            self?.player?.play();
        }*/
        
        let videoURL = URL(string: post.videoLink)
        let player = AVPlayer(url: videoURL!)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.frame = self.previewVideoView.layer.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        player.automaticallyWaitsToMinimizeStalling = false
        self.previewVideoView.layer.addSublayer(avPlayerLayer)
        player.play()
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
