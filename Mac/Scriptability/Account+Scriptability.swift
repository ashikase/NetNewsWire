//
//  Account+Scriptability.swift
//  NetNewsWire
//
//  Created by Olof Hellman on 1/9/18.
//  Copyright © 2018 Olof Hellman. All rights reserved.
//

import AppKit
import Account
import Articles
import RSCore

@objc(ScriptableAccount)
final class ScriptableAccount: NSObject, UniqueIdScriptingObject, ScriptingObjectContainer {

    let account: Account
    init (_ account: Account) {
        self.account = account
    }

    @objc(objectSpecifier)
    override var objectSpecifier: NSScriptObjectSpecifier? {
        let myContainer = NSApplication.shared
        let scriptObjectSpecifier = myContainer.makeFormUniqueIDScriptObjectSpecifier(forObject: self)
        return (scriptObjectSpecifier)
    }

	@objc(scriptingIsActive)
	var scriptingIsActive: Bool {
		get {
			return account.isActive
		}
		set {
			account.isActive = newValue
		}
	}

	@objc(scriptingName)
	var scriptingName: NSString {
		get {
			return account.nameForDisplay as NSString
		}
		set {
			account.name = newValue as String
		}
	}

    // MARK: --- ScriptingObject protocol ---

    var scriptingKey: String {
        return "accounts"
    }

    // MARK: --- UniqueIdScriptingObject protocol ---

    // I am not sure if account should prefer to be specified by name or by ID
    // but in either case it seems like the accountID would be used as the keydata, so I chose ID
    @objc(uniqueId)
    var scriptingUniqueId: Any {
        return account.accountID
    }

    // MARK: --- ScriptingObjectContainer protocol ---

    var scriptingClassDescription: NSScriptClassDescription {
        return self.classDescription as! NSScriptClassDescription
    }

	func deleteElement(_ element: ScriptingObject) {
		if let scriptableFolder = element as? ScriptableFolder {
			BatchUpdate.shared.perform {
				account.removeFolder(scriptableFolder.folder) { _ in
				}
			}
		} else if let scriptableFeed = element as? ScriptableFeed {
			BatchUpdate.shared.perform {
				var container: Container?
				if let scriptableFolder = scriptableFeed.container as? ScriptableFolder {
					container = scriptableFolder.folder
				} else {
					container = account
				}
				account.removeFeed(scriptableFeed.feed, from: container!) { _ in
				}
			}
		}
	}

    @objc(isLocationRequiredToCreateForKey:)
    func isLocationRequiredToCreate(forKey key: String) -> Bool {
       return false
    }

    // MARK: --- Scriptable elements ---

    @objc(feeds)
    var feeds: NSArray {
        return account.topLevelFeeds.map { ScriptableFeed($0, container: self) } as NSArray
    }

    @objc(valueInFeedsWithUniqueID:)
    func valueInFeeds(withUniqueID id: String) -> ScriptableFeed? {
		guard let feed = account.existingFeed(withFeedID: id) else { return nil }
        return ScriptableFeed(feed, container: self)
    }

    @objc(valueInFeedsWithName:)
    func valueInFeeds(withName name: String) -> ScriptableFeed? {
		let feeds = Array(account.flattenedFeeds())
        guard let feed = feeds.first(where: {$0.name == name}) else { return nil }
        return ScriptableFeed(feed, container: self)
    }

    @objc(folders)
    var folders: NSArray {
		let foldersSet = account.folders ?? Set<Folder>()
		let folders = Array(foldersSet)
		return folders.map { ScriptableFolder($0, container: self) } as NSArray
    }

    @objc(valueInFoldersWithUniqueID:)
    func valueInFolders(withUniqueID id: NSNumber) -> ScriptableFolder? {
        let folderId = id.intValue
		let foldersSet = account.folders ?? Set<Folder>()
		let folders = Array(foldersSet)
        guard let folder = folders.first(where: {$0.folderID == folderId}) else { return nil }
        return ScriptableFolder(folder, container: self)
    }

    // MARK: --- Scriptable properties ---

    @objc(allFeeds)
    var allFeeds: NSArray {
		var feeds = [ScriptableFeed]()
		for feed in account.topLevelFeeds {
			feeds.append(ScriptableFeed(feed, container: self))
		}
		if let folders = account.folders {
			for folder in folders {
				let scriptableFolder = ScriptableFolder(folder, container: self)
				for feed in folder.topLevelFeeds {
					feeds.append(ScriptableFeed(feed, container: scriptableFolder))
				}
			}
		}
		return feeds as NSArray
    }

    @objc(opmlRepresentation)
    var opmlRepresentation: String {
        return self.account.OPMLString(indentLevel: 0)
    }

    @objc(accountType)
	var accountType: OSType {
		var osType: String = ""
		switch self.account.type {
		case .onMyMac:
			osType = "Locl"
		case .cloudKit:
			osType = "Clkt"
		case .feedly:
			osType = "Fdly"
		case .feedbin:
			osType = "Fdbn"
		case .newsBlur:
			osType = "NBlr"
		case .freshRSS:
			osType = "Frsh"
		case .inoreader:
			osType = "Inrd"
		case .bazQux:
			osType = "Bzqx"
		case .theOldReader:
			osType = "Tord"
		}
		return osType.fourCharCode
	}
}
