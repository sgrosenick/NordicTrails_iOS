//
//  TrailsTableViewCell.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/10/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import UIKit

class TrailsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func contentSetup(TrailsModel: TrailsModel) {
        titleLabel.text = TrailsModel.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowOffset = CGSize.zero
        cellView.layer.shadowColor = UIColor.darkGray.cgColor
        cellView.layer.cornerRadius = 10
    }

}
