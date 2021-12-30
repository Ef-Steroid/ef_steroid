//
// Created by TabooSun on 30/12/2021.
//

import Foundation

protocol IMenuBarService : PlatformChannelProtocol {
	/// Raise a signal from native to Flutter when the user clicks the menu bar `Preferences`.
	func openPreference() throws
}
