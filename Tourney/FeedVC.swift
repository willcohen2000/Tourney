//
//  FeedVC.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postBtn: UIButton!
    
    @IBOutlet weak var firstHolderView: UIView!
    @IBOutlet weak var firstUserImage: UIImageView!
    @IBOutlet weak var firstUserName: UILabel!
    @IBOutlet weak var firstViews: UILabel!
    
    @IBOutlet weak var secondHolderView: UIView!
    @IBOutlet weak var secondUserImage: UIImageView!
    @IBOutlet weak var secondUserName: UILabel!
    @IBOutlet weak var secondViews: UILabel!
    
    @IBOutlet weak var thirdHolderView: UIView!
    @IBOutlet weak var thirdUserImage: UIImageView!
    @IBOutlet weak var thirdUserName: UILabel!
    @IBOutlet weak var thirdViews: UILabel!
    
    var posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var selectedImage: UIImage!
    var userImage: String!
    var userName: String!
    
    var currentCell: PostCell!
    var cells: [PostCell] = [];
    
    var selectedVideo: Post!
    var queried: [Post] = []
    
    override func viewDidAppear(_ animated: Bool) {
        loadDataAndResetTable()
        if let currentCell = currentCell {
            currentCell.isActive();
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let currentCell = currentCell {
             currentCell.isUnactive()
        }
    }
    
    private func configureViews() {
        firstHolderView.layer.cornerRadius = 10.0;
        firstHolderView.layer.borderColor = UIColor.black.cgColor;
        firstHolderView.layer.borderWidth = 1.0;
        secondHolderView.layer.cornerRadius = 10.0;
        secondHolderView.layer.borderColor = UIColor.black.cgColor;
        secondHolderView.layer.borderWidth = 1.0;
        thirdHolderView.layer.cornerRadius = 10.0;
        thirdHolderView.layer.borderColor = UIColor.black.cgColor;
        thirdHolderView.layer.borderWidth = 1.0;
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        loadDataAndResetTable()
        configureViews()
        
        sortTopVideos()
    }
    
    private func sortTopVideos() {
        let ref = Database.database().reference().child("posts")
        var queriedPosts: [Post] = []
        //change when eventID changes ====================================================
        let eventID = "pennstate"
        let query = ref.queryOrdered(byChild: "eventID").queryEqual(toValue: eventID)
        query.observe(.value, with: { (snapshot) in
            if let childSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                queriedPosts.removeAll()
                for data in childSnapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject>{
                        let key = data.key
                        let post = Post(postKey: key, postData: postDict)
                        queriedPosts.append(post)
                    }
                }
            }

            queriedPosts = queriedPosts.sorted(by: { $0.views > $1.views })
            self.queried = queriedPosts
            if (queriedPosts.count == 1) {
                self.updateUITopVideos(topVideos: [queriedPosts[0]], any: true)
            } else if (queriedPosts.count == 2) {
                self.updateUITopVideos(topVideos: [queriedPosts[0], queriedPosts[1]], any: true)
            } else if (queriedPosts.count == 0) {
                self.updateUITopVideos(topVideos: [], any: false)
            } else {
                self.updateUITopVideos(topVideos: [queriedPosts[0], queriedPosts[1] , queriedPosts[2]], any: true)
            }
        })
    }
    
    private func updateUITopVideos(topVideos: [Post?], any: Bool) {
        if let _ = topVideos[exist: 0] {
            self.firstUserName.text = topVideos[0]!.username
            self.firstViews.text = "\(topVideos[0]!.views)"
            downloadImage(from: URL(string: topVideos[0]!.userImg)!, imageView: firstUserImage)
        }
        if let _ = topVideos[exist: 1] {
            self.secondUserName.text = topVideos[1]!.username
            self.secondViews.text = "\(topVideos[1]!.views)"
            downloadImage(from: URL(string: topVideos[1]!.userImg)!, imageView: secondUserImage)
        }
        if let _ = topVideos[exist: 2] {
            self.thirdUserName.text = topVideos[2]!.username
            self.thirdViews.text = "\(topVideos[2]!.views)"
            downloadImage(from: URL(string: topVideos[2]!.userImg)!, imageView: thirdUserImage)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func loadDataAndResetTable() {
        Database.database().reference().child("posts").observe(.value, with: {
            (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.posts.removeAll()
                for data in snapshot{
                    print(data)
                    if let postDict = data.value as? Dictionary<String, AnyObject>{
                        let key = data.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
                
            }
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let activeCell = cell as! PostCell;
        activeCell.isUnactive();
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("hello!")
        let activeCell = cell as! PostCell;
        currentCell = activeCell;
        currentCell.player.play()
        activeCell.isActive();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            cell.configCell(post: post)
            cell.isActive()
            cells.append(cell)
            return cell
        } else {
            return PostCell()
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImage = image
            imageSelected = true
            
            
        } else {
            print("a valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        guard imageSelected == true else{
            print("An image needs to be selected")
            return
        }
        if let imgData = selectedImage.jpegData(compressionQuality: 0.2){
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            let storageRef = Storage.storage().reference().child("post-pics").child(imgUid)
            storageRef.putData(imgData, metadata: metadata){
                (metadata, error) in
                if error != nil{
                    print("did not upload image")
                } else {
                    print("Image was saved")
                    storageRef.downloadURL(completion: {url, error in
                        if let _ = error {
                            print("error")
                        } else {
                            print((url?.absoluteString)!)
                            
                            self.postToFireBase(imgUrl: url!.absoluteString)
                            print("HELLO")
                        }
                    })
                    
                }
            }
        }
    }
    
    func postToFireBase(imgUrl: String){
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            let post: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "imageUrl": imgUrl as AnyObject,
                "likes": 0 as AnyObject
            ]
            let firebasePost = Database.database().reference().child("posts").childByAutoId()
            firebasePost.setValue(post)
            self.imageSelected = false
            self.tableView.reloadData()
        })
        
    }
    
    @IBAction func postImageTapped(_ sender: AnyObject){
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func SignOut (_sender: AnyObject){
        try! Auth.auth().signOut()
        
        KeychainWrapper.standard.removeObject(forKey: "uid")
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTopVideo" {
            if let destination = segue.destination as? TopVideoController {
                destination.post = self.selectedVideo
            }
        }
    }
    
    @IBAction func firstVideoPressed(_ sender: Any) {
        self.selectedVideo = queried[0]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        self.selectedVideo = queried[1]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        self.selectedVideo = queried[1]
        self.performSegue(withIdentifier: "toTopVideo", sender: nil)
    }
    
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}















