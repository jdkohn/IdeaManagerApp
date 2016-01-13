//
//  IdeaCell.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/5/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class IdeaCell: UITableViewCell {
    
    @IBOutlet weak var checkedButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}