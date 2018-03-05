//
//  DataSource.swift
//  FireMock
//
//  Created by Albert Arroyo on 3/3/18.
//

import UIKit

class FireMockDataSource: NSObject, FireMockSourceType {
    var dataObject: FireMockDataType

    init<A: FireMockDataType>(dataObject: A) {
        self.dataObject = dataObject
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataObject.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataObject.numberOfItems(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("This method must be overridden")
    }

}

protocol FireMockDataType {
    var numberOfSections: Int { get }
    func numberOfItems(section: Int) -> Int
}

protocol FireMockSourceType: UITableViewDataSource {
    var dataObject: FireMockDataType { get set }
}
