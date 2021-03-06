//
//  TopCell.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 4/6/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class TopCell: UITableViewCell {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var down: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
