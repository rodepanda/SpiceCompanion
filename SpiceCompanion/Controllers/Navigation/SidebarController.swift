//
//  SidebarController.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// The view controller containing the sidebar within a `MainController` when using a regular horizontal
/// size class.
class SidebarController: UICollectionViewController {

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ListItem>
    private typealias HeaderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Section>
    private typealias TabCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, MainTab>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ListItem>
    private typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>

    /// The backing data source of this controller.
    private lazy var dataSource: DataSource = {
        let headerCellRegistration = HeaderCellRegistration { [unowned self] cell, indexPath, section in
            var content = cell.defaultContentConfiguration()
            content.text = section.name
            cell.contentConfiguration = content

            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
        }

        let tabCellRegistration = TabCellRegistration { [unowned self] cell, indexPath, tab in
            var content = cell.defaultContentConfiguration()
            content.image = tab.outlinedIcon
            content.text = tab.name
            cell.contentConfiguration = content
        }

        let dataSource = DataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, item in
            switch item {
            case .header(let section):
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: section)
            case .tab(let tab):
                return collectionView.dequeueConfiguredReusableCell(using: tabCellRegistration, for: indexPath, item: tab)
            }
        }

        return dataSource
    }()

    init(tabs: [MainTab]) {
        // configure the collection view to display a sidebar with headers
        var layoutConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        layoutConfiguration.headerMode = .firstItemInSection

        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfiguration)
        super.init(collectionViewLayout: layout)
        navigationItem.title = "Deep Space 9" //TODO: name

        // apply the sidebar model
        // the data never changes so apply a single snapshot on load
        let sections = [
            Section(name: "Spice", tabs: tabs),
        ]

        // create the sections
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot)

        // create the items for each section
        for section in sections {
            var sectionSnapshot = SectionSnapshot()
            let headerItem = ListItem.header(section: section)
            sectionSnapshot.append([headerItem])
            sectionSnapshot.append(section.tabs.map { .tab(tab: $0) }, to: headerItem)
            sectionSnapshot.expand([headerItem])
            dataSource.apply(sectionSnapshot, to: section, animatingDifferences: false)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Data Structures

extension SidebarController {
    /// A single, collapsible section of tabs within a sidebar.
    private struct Section: Hashable {

        /// The display name of this section.
        let name: String

        /// All the tabs within this section.
        let tabs: [MainTab]

        func hash(into hasher: inout Hasher) {
            name.hash(into: &hasher)
        }
    }
}

// MARK: - Enumerations

extension SidebarController {
    /// A single item within a sidebar.
    private enum ListItem: Hashable {
        /// A section header.
        case header(section: Section)

        /// A tab.
        case tab(tab: MainTab)
    }
}
