//
//  ParksTableViewCell.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/4/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import UIKit

class ParksTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    func contentSetup (ParksModel: ParksModel) {
        titleLabel.text = ParksModel.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowOffset = CGSize.zero
        cellView.layer.shadowColor = UIColor.darkGray.cgColor
        cellView.layer.cornerRadius = 10
    }
}
