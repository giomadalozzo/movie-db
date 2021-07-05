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
    var genres: [Genres] = []
    var stringGenres: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.stringGenres = generateGenresString(genres: film!.genres)
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
            cell?.starsCell.text = String(self.film!.voteAverage)
            cell?.genresCell.text = self.stringGenres
            
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
    
    func generateGenresString(genres: [Int]) -> String {
        var string: String = ""
        
        for genreID in genres{
            for genre in self.genres{
                if genre.id == genreID {
                    string = string + genre.genre + ", "
                }
            }
        }
        var stringOutput = String(string.dropLast().dropLast())
        
        return stringOutput
    }

}
