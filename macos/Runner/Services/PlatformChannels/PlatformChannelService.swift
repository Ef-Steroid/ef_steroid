//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import FlutterMacOS

class PlatformChannelService : IPlatformChannelService {
	private let menuBarService: IMenuBarService

	init(menuBarService: IMenuBarService) {
		self.menuBarService = menuBarService
	}

	func register(registry: FlutterViewController) {
		menuBarService.register(registry: registry)
	}
}
