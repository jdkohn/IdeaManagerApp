//
//  StepCell.swift
//  
//
//  Created by Jacob Kohn on 1/13/16.
//
//

import Foundation
import UIKit

class StepCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var up: UIButton!
    @IBOutlet weak var down: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}