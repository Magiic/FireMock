//
//  FireMockDataSource.swift
//  FireMock
//
//  Created by Albert Arroyo on 3/3/18.
//

import UIKit

/// Class to prepare Category Section for Collasped / Expanded
class FireMockCategorySection {
    var title: String
    var mocks: [FireMock.ConfigMock]
    var collapsed: Bool

    init(title: String, mocks: [FireMock.ConfigMock], collapsed: Bool = true) {
        self.title = title
        self.mocks = mocks
        self.collapsed = collapsed
    }
}

/// DataType for FireMock
class FireMockCategoriesDataType {

    var configMockSections: [FireMockCategorySection]

    init(mockSections: [FireMockCategorySection]) {
        self.configMockSections = mockSections
    }

}

extension FireMockCategoriesDataType: FireMockDataType {
    var numberOfSections: Int {
        return configMockSections.count
    }
    func numberOfItems(section: Int) -> Int {
        return configMockSections[section].mocks.count
    }
}


/// DataSource for FireMockViewController
class FireMockTableDataSource: FireMockDataSource {

    // MARK: Injected
    var tableView: UITableView!

    init(tableView: UITableView, dataType: FireMockCategoriesDataType) {
        self.tableView = tableView
        super.init(dataObject: dataType)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataObject.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataObject = dataObject as? FireMockCategoriesDataType else {
            return 0
        }
        let subCategories = dataObject.configMockSections[section].mocks
        return dataObject.configMockSections[section].collapsed ? 0 : subCategories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let categoryData = dataObject as? FireMockCategoriesDataType else {
            fatalError("Could not dequeue WayfindingCategoryCell or dataObject doesn't match")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "FireMockTableViewCell", for: indexPath) as! FireMockTableViewCell

        var mock = categoryData.configMockSections[indexPath.section].mocks[indexPath.row]

        cell.configure(mock: mock)
        cell.enabled = { on in
            mock.enabled = on
            FireMock.update(configMock: mock)
        }
        return cell
    }

}

// MARK: - CollapsibleTableViewHeaderDelegate
extension FireMockTableDataSource: CollapsibleTableViewHeaderDelegate {

    /// Method when section is selected
    /// - Parameters:
    ///   - header: FireMockTableViewHeaderCell
    ///   - section: Int
    func toggleSection(_ header: FireMockTableViewHeaderCell, section: Int) {
        guard let sectionsData = dataObject as? FireMockCategoriesDataType else {
            return
        }

        let categorySection: FireMockCategorySection = sectionsData.configMockSections[section]
        let collapsed = categorySection.collapsed

        // Toggle collapse
        categorySection.collapsed = !collapsed
        header.setCollapsed(!collapsed)

        let rows = categorySection.mocks
        var indexPaths: [IndexPath] = []
        for (index, _) in rows.enumerated() {
            indexPaths.append(IndexPath(item: index, section: section))
        }

        tableView.beginUpdates()
        if collapsed {
            //insert rows
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            //delete rows
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()

    }
}
