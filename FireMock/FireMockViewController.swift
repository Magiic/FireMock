//
//  FireMockViewController.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import UIKit

public class FireMockViewController: UIViewController {

    @IBOutlet weak var enabledFireMock: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    var backTapped: (() -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()

        registerXib()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        enabledFireMock.isOn = FireMock.isEnabled
    }

    @IBAction func enabledFireMock(sender: UISwitch) {
        FireMock.enabled(sender.isOn)
        if let sessionConf = defaultSessionConf {
            FireMock.enabled(sender.isOn, forConfiguration: sessionConf)
        }
    }

    @IBAction func back(_ sender: Any) {
        backTapped?()
        dismiss(animated: true, completion: nil)
    }

    private func registerXib() {
        let nib = UINib(nibName: "FireMockTableViewCell", bundle: Bundle(for: FireMockTableViewCell.self))
        tableView.register(nib, forCellReuseIdentifier: "FireMockTableViewCell")
    }
}

extension FireMockViewController: UINavigationBarDelegate {
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension FireMockViewController: UITableViewDataSource, UITableViewDelegate {

    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FireMock.mocks.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FireMockTableViewCell", for: indexPath) as! FireMockTableViewCell

        var mock = FireMock.mocks[indexPath.row]

        cell.configure(mock: mock)
        cell.enabled = { on in
            mock.enabled = on
            FireMock.update(configMock: mock)
        }

        return cell
    }
}
