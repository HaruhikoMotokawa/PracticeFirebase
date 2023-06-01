//
//  CustomTableViewCell.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/26.
//

import UIKit

class CustomTableViewCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var numberLabel: UILabel!

    @IBOutlet weak var unitLabel: UILabel!

    var itemModelList: [ItemModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    func setItem(name: String, number: String, unit: String) {
        nameLabel.text = name
        numberLabel.text = number
        unitLabel.text = unit
    }
}
