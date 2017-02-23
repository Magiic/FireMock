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

    var backTapped: (() -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()

        registerXib()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        automaticallyAdjustsScrollViewInsets = false

        enabledFireMock.isOn = FireMock.isEnabled

        setupNavBar()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    private func setupNavBar() {
        self.title = "Mock Registers"
        let backButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(FireMockViewController.back(_:)))
        backButtonItem.tintColor = .black

        self.navigationItem.leftBarButtonItem = backButtonItem
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

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let configMock = FireMock.mocks[indexPath.row]

        if configMock.mocks.count > 1 {
            let mockSelectionController = FireMockSelectionTableViewController(nibName: "FireMockSelectionTableViewController", bundle: Bundle(for: FireMockSelectionTableViewController.self))
            mockSelectionController.configMock = configMock

            self.navigationController?.pushViewController(mockSelectionController, animated: true)
        }
    }
}
