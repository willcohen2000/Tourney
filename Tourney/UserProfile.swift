//
//  UserProfile.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 6/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit

class UserProfile: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
    }

    

}
