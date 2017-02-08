//
//  FireMockTableViewCell.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import UIKit

class FireMockTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var httpMethod: UILabel!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!

    var enabled: ((_ on: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(mock: FireMock.ConfigMock) {
        httpMethod.text = mock.httpMethod.rawValue
        name.text = mock.mock.name
        url.text = mock.url.absoluteString
        enabledSwitch.isOn = mock.enabled
    }

    @IBAction func enabledMock(sender: UISwitch) {
        enabled?(sender.isOn)
    }
    
}
