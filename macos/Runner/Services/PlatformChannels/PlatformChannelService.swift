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

	static func createFlutterMethodChannel(of: PlatformChannelProtocol, registry: FlutterViewController) -> FlutterMethodChannel {
		FlutterMethodChannel(
				name: "\(Bundle.main.bundleIdentifier!)/\(String(describing: type(of: of)))",
				binaryMessenger: registry.engine.binaryMessenger
		)
	}
}
