//
//  TimelinePreviewTableViewController.swift
//  NetNewsWire-iOS
//
//  Created by Maurice Parker on 11/8/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import UIKit
import Articles

class TimelinePreviewTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self

    }

	func heightFor(width: CGFloat) -> CGFloat {
		if UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
			let layout = MainTimelineAccessibilityCellLayout(width: width, insets: tableView.safeAreaInsets, cellData: prototypeCellData)
			return layout.height
		} else {
			let layout = MainTimelineDefaultCellLayout(width: width, insets: tableView.safeAreaInsets, cellData: prototypeCellData)
			return layout.height
		}
	}

	// MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTimelineTableViewCell
		cell.cellData = prototypeCellData
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
	}
	// MARK: API

	func reload() {
		tableView.reloadData()
	}

}

// MARK: Private

private extension TimelinePreviewTableViewController {

	var prototypeCellData: MainTimelineCellData {
		let longTitle = Constants.prototypeText

		let prototypeID = "prototype"
		let status = ArticleStatus(articleID: prototypeID, read: false, starred: false, dateArrived: Date())
		let prototypeArticle = Article(
			accountID: prototypeID,
			articleID: prototypeID,
			feedID: prototypeID,
			uniqueID: prototypeID,
			title: longTitle, contentHTML: nil,
			contentText: nil,
			url: nil,
			externalURL: nil,
			summary: nil,
			imageURL: nil,
			datePublished: nil,
			dateModified: nil,
			authors: nil,
			status: status
		)

		let iconImage = IconImage(AppAssets.faviconTemplateImage.withTintColor(AppAssets.secondaryAccentColor))

		return MainTimelineCellData(
			article: prototypeArticle,
			showFeedName: .feed,
			feedName: "Feed Name",
			byline: nil, iconImage: iconImage,
			showIcon: true,
			numberOfLines: AppDefaults.shared.timelineNumberOfLines,
			iconSize: AppDefaults.shared.timelineIconSize
		)
	}
}
