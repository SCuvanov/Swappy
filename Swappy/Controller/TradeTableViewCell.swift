//
//  TradeTableViewCell.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/14/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import SwipeCellKit

class TradeTableViewCell: SwipeTableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {}

    @IBAction func tradeButtonPressed(_ sender: UIButton) {
    }
}
