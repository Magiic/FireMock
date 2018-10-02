//
//  FireMockSelectionTableViewController.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 22/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import UIKit

class FireMockSelectionTableViewController: UITableViewController {

    var configMock: FireMock.ConfigMock!
    private var items: [FireMockProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        items = configMock.mocks

        registerXib()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }

    private func registerXib() {
        let nib = UINib(nibName: "FireMockSelectionTableViewCell", bundle: Bundle(for: FireMockSelectionTableViewCell.self))
        tableView.register(nib, forCellReuseIdentifier: "FireMockSelectionTableViewCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FireMockSelectionTableViewCell", for: indexPath) as! FireMockSelectionTableViewCell

        let mockProtocol = items[indexPath.row]
        let name = mockProtocol.name ?? "No Name"
        cell.configure(name: name, filename: mockProtocol.mockFile())

        if indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        replaceElementAtFirst(fromIndex: indexPath.row, in: &items)
        var newConfigMock = configMock
        newConfigMock?.mocks = items

        FireMock.update(configMock: newConfigMock!)

        let _ = self.navigationController?.popViewController(animated: true)
    }

    private func replaceElementAtFirst(fromIndex index: Int, in array: inout [FireMockProtocol]) {
        let element = array.remove(at: index)
        array.insert(element, at: 0)
    }
    
}
