//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import FlutterMacOS

class MenuBarService : IMenuBarService {
	lazy var methodChannel: FlutterMethodChannel? = nil

	func register(registry: FlutterViewController) {
		methodChannel = PlatformChannelService.createFlutterMethodChannel(of: self, registry: registry)
	}

	func openPreference() throws {
		try ensureInitialize()

		methodChannel!.invokeMethod(PlatformChannelKeys.openPreferenceMethodKey, arguments: nil)
	}

	private func ensureInitialize() throws {
		if (methodChannel == nil) {
			throw PlatformChannelUninitializedError()
		}
	}
}
