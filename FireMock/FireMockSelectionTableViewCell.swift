//
//  FireMockSelectionTableViewCell.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 22/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import UIKit

class FireMockSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var filename: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(name: String?, filename: String) {
        self.name.text = name
        self.filename.text = filename
    }
    
}
