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
    
}

class TableViewController: UITableViewController {
    
    var data = [CellData]()
    var identities = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [CellData.init(image: #imageLiteral(resourceName: "Beaver Stadium Night"), message: "Beaver Stadium, PA"),CellData.init(image: #imageLiteral(resourceName: "Portugal"), message: "Lisbon, Portugal"),
        CellData.init(image: #imageLiteral(resourceName: "Screen Shot 2018-09-14 at 12.08.52 PM"), message: "Lisbon, Portugal")]
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        identities = ["One","Two"]
    }

    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let vcName = identities[indexPath.row]
        let viewController = storyboard?.instantiateViewController(withIdentifier: vcName )
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
 


}
