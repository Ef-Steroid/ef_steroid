//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import NeedleFoundation

class PlatformChannelComponent : Component<EmptyDependency> {
	var platformChannelService: IPlatformChannelService {
		shared {
			PlatformChannelService(menuBarService: menuBarService)
		}
	}
	var menuBarService: IMenuBarService {
		shared {
			MenuBarService()
		}
	}
}
