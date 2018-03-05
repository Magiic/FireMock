//
//  FireMockTableViewHeaderCell.swift
//  FireMock
//
//  Created by Albert Arroyo on 3/3/18.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate: class {
    func toggleSection(_ header: FireMockTableViewHeaderCell, section: Int)
}

public final class FireMockTableViewHeaderCell: UITableViewHeaderFooterView {

    enum Constants {
        static let categoryNameFontSize: CGFloat = 17.0
        static let categoryNameFont: UIFont = UIFont.boldSystemFont(ofSize: Constants.categoryNameFontSize)
        static let categoryNameColor: UIColor = UIColor.black
        static let categoryContentBackgroundColor: UIColor = UIColor.lightGray
        static let categoryContentCollapsedBackgroundColor: UIColor = UIColor.white
        static let categoryArrow: UIImage? = UIImage(
            named: "fireMock_arrowRight",
            in: Bundle(for: FireMockTableViewHeaderCell.self),
            compatibleWith: nil)
        static let categoryArrowCollapsed: UIImage? = UIImage(
            named: "fireMock_plus",
            in: Bundle(for: FireMockTableViewHeaderCell.self),
            compatibleWith: nil)
        static let categoryArrowExpanded: UIImage? = UIImage(
            named: "fireMock_minus",
            in: Bundle(for: FireMockTableViewHeaderCell.self),
            compatibleWith: nil)
    }

    @IBOutlet var categoryNameLabel: UILabel! {
        didSet {
            self.categoryNameLabel.font = Constants.categoryNameFont
            self.categoryNameLabel.textColor = Constants.categoryNameColor
        }
    }
    @IBOutlet var categoryArrow: UIImageView!

    weak var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    var categorySection: FireMockCategorySection!

    override public func awakeFromNib() {
        super.awakeFromNib()
        addTapGesture()
    }

    private func addTapGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FireMockTableViewHeaderCell.tapHeader(_:))))
    }

    /// Method to trigger toggle section when tapping on the header
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? FireMockTableViewHeaderCell else {
            return
        }

        delegate?.toggleSection(self, section: cell.section)
    }

    /// Method to react when the cell will be collapsed or expanded
    /// - Parameter collapsed: Bool
    func setCollapsed(_ collapsed: Bool) {
        animateArrowWithSubcategories(collapsed)
    }

    /// Method to animathe the arrow when there's subcategories
    /// - Parameter collapsed: Bool
    private func animateArrowWithSubcategories(_ collapsed: Bool) {
        UIView.transition(with: categoryArrow, duration: 0.2, options: .transitionCrossDissolve,
                          animations: {
                            self.contentView.backgroundColor = collapsed ? Constants.categoryContentCollapsedBackgroundColor : Constants.categoryContentBackgroundColor
                            self.categoryArrow.image = collapsed ? Constants.categoryArrowCollapsed : Constants.categoryArrowExpanded
        }, completion: nil)
    }

    func configure(data: FireMockCategorySection) {
        self.categorySection = data
        setupView(categorySection: data)
    }

    private func setupView(categorySection: FireMockCategorySection) {
        categoryNameLabel.text = categorySection.title
        categoryArrow.image = categorySection.collapsed ? Constants.categoryArrowCollapsed : Constants.categoryArrowExpanded
    }
}
