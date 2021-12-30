//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import FlutterMacOS

class MenuBarService : IMenuBarService {
	var methodChannel: FlutterMethodChannel?

	func register(registry: FlutterViewController) {
		print(type(of: self))
		methodChannel = FlutterMethodChannel(
				name: "\(Bundle.main.bundleIdentifier!)/menuBar",
				binaryMessenger: registry.engine.binaryMessenger
		)
	}

	func openPreference() throws {
		try ensureInitialize()

		methodChannel!.invokeMethod("openPreference", arguments: nil)
	}

	private func ensureInitialize() throws {
		if (methodChannel == nil) {
			throw PlatformChannelUninitializedError()
		}
	}
}
