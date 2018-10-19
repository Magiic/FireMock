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
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 80
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = 64
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.sectionFooterHeight = 0
        }
    }

    var backTapped: (() -> Void)?

    private var dataSource: FireMockDataSource!

    override public func viewDidLoad() {
        super.viewDidLoad()

        registerXib()
        automaticallyAdjustsScrollViewInsets = false
        enabledFireMock.isOn = FireMock.isEnabled

        setupNavBar()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupDataSource()
    }

    private func setupDataSource() {
        let mocks = FireMock.mocks
        let mocksCategorized = mocks.categorise { $0.mocks[0].category! }
        var categorySections: [FireMockCategorySection] = []
        mocksCategorized.forEach { (key: String, value: [FireMock.ConfigMock]) in
            let categorySection = FireMockCategorySection(title: key, mocks: value, collapsed: true)
            categorySections.append(categorySection)
        }
        let dataType = FireMockCategoriesDataType(mockSections: categorySections)
        dataSource = FireMockTableDataSource(tableView: tableView, dataType: dataType)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }

    private func setupNavBar() {
        self.title = "Mock Registers"

        let buttonTitle: String
        if self.isModal {
            buttonTitle = "Done"
        } else {
            buttonTitle = "Back"
        }
        let backButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(FireMockViewController.back(_:)))
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

        let nibHeader = UINib(nibName: "FireMockTableViewHeaderCell", bundle: Bundle(for: FireMockTableViewHeaderCell.self))
        tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: "FireMockTableViewHeaderCell")
    }
}

extension FireMockViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionsData = dataSource.dataObject as? FireMockCategoriesDataType else {
            return nil
        }
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FireMockTableViewHeaderCell") as? FireMockTableViewHeaderCell else {
            return nil
        }
        let sectionData: FireMockCategorySection = sectionsData.configMockSections[section]
        header.configure(data: sectionData)
        header.section = section
        header.delegate = dataSource as? CollapsibleTableViewHeaderDelegate

        return header
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        guard let sectionsData = dataSource.dataObject as? FireMockCategoriesDataType else {
            return
        }
        let configMock = sectionsData.configMockSections[indexPath.section].mocks[indexPath.row]

        if configMock.mocks.count > 1 {
            let mockSelectionController = FireMockSelectionTableViewController(nibName: "FireMockSelectionTableViewController", bundle: Bundle(for: FireMockSelectionTableViewController.self))
            mockSelectionController.configMock = configMock

            self.navigationController?.pushViewController(mockSelectionController, animated: true)
        }
    }
}

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

public extension Sequence {
    func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
