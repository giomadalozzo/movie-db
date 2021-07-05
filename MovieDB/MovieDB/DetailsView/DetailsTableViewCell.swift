//
//  DetailsTableViewCell.swift
//  MovieDB
//
//  Created by Giovanni Madalozzo on 04/07/21.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var genresCell: UILabel!
    @IBOutlet weak var starCell: UIImageView!
    @IBOutlet weak var starsCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
