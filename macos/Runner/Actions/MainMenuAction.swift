//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import Cocoa

class MainMenuAction {
	static func onMainMenuPreferencePressed(_ sender: NSMenuItem) {
		let rootComponent = RootComponent()
		let menuBarService = rootComponent.platformChannelComponent.menuBarService
		try! menuBarService.openPreference()
	}
}
