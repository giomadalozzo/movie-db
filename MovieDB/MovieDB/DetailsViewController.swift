//
//  DetailsViewController.swift
//  MovieDB
//
//  Created by Giovanni Madalozzo on 04/07/21.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var film: Film?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainDetails", for: indexPath) as? DetailsTableViewCell
            cell?.imageCell.image = self.film?.image
            cell?.imageCell.layer.cornerRadius = 20
            cell?.titleCell.text = self.film?.title
            cell?.starCell.image = UIImage(systemName: "star")
            
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "overview", for: indexPath) as? UITableViewCell
            cell?.textLabel!.text = "Overview"
            cell?.detailTextLabel!.text = self.film?.overview
            cell?.detailTextLabel?.numberOfLines = 0
            cell?.detailTextLabel?.lineBreakMode = .byWordWrapping
            
            return cell!
        }
    }

}
