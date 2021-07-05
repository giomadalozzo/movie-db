//
//  MoviesTableViewCell.swift
//  MovieDB
//
//  Created by Giovanni Madalozzo on 03/07/21.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var textCell: UILabel!
    @IBOutlet weak var starsCell: UILabel!
    @IBOutlet weak var starCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
