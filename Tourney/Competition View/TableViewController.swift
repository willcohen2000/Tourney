//
//  TableViewController.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit

struct CellData {
    
    let image: UIImage?
    let message: String?
    let filter: String?
    
}

class TableViewController: UITableViewController {
    
    var data = [CellData]()
    var selectedFilter: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [CellData(image: UIImage(named: "Beaver Stadium Night"), message: "Beaver Stadium, PA", filter: "pennstate"), CellData(image: UIImage(named: "Portugal"), message: "Lisbon, Portugal", filter: "lisbon")]
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        cell.mainImage = data[indexPath.row].image
        cell.message = data[indexPath.row].message
        cell.layoutSubviews()
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = data[indexPath.row].filter!
        self.performSegue(withIdentifier: "toVideoFeed", sender: nil)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoFeed" {
            if let destination = segue.destination as? FeedVC {
                User.sharedInstance.activeFilter = self.selectedFilter
                destination.activeFilter = self.selectedFilter
            }
        }
    }

}
