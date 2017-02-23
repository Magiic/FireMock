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
    @IBOutlet weak var parameters: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!

    var enabled: ((_ on: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(mock: FireMock.ConfigMock) {
        httpMethod.text = mock.httpMethod.rawValue
        self.name.text = mock.mocks.first?.name ?? "No Name"
        url.text = mock.url?.absoluteString ?? mock.regex
        parameters.text = parametersNames(mock: mock)
        enabledSwitch.isOn = mock.enabled

        if mock.mocks.count > 1 {
            accessoryType = .disclosureIndicator
        } else {
            accessoryType = .none
        }
    }

    @IBAction func enabledMock(sender: UISwitch) {
        enabled?(sender.isOn)
    }

    // MARK: - Helper

    private func parametersNames(mock: FireMock.ConfigMock) -> String {
        if let mockFind = mock.mocks.first, let params = mockFind.parameters {
            return params.joined(separator: "/")
        }

        if let url = mock.url {
            let urlComponents = URLComponents(string: url.absoluteString)
            if let queryItems = urlComponents?.queryItems {
                return queryItems.map({ $0.name }).joined(separator: "/")
            }
        }

        if let _ = mock.regex {
            return "Regex used"
        }

        return "0 parameters"
    }
    
}
