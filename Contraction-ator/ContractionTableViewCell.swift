//
//  ContractionTableViewCell.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/13/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit

class ContractionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var dateHadLabel: UILabel!
    @IBOutlet weak var timeSinceLastLabel: UILabel!
    @IBOutlet weak var dialationLabel: UILabel!
    @IBOutlet weak var avgContractionLabel: UILabel!
    @IBOutlet weak var avgApartLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noteLabel.alpha = 0.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
