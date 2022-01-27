//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import FlutterMacOS

protocol PlatformChannelProtocol {
	var methodChannel: FlutterMethodChannel? { get }

	func register(registry: FlutterViewController) -> Void
}
