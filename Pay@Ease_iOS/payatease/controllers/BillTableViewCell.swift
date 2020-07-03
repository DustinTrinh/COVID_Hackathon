//
//  BillTableViewCell.swift
//  payatease
//
//  Created by Andy Lin on 2020-07-02.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var id: UILabel!
    
    @IBOutlet weak var receiver: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
