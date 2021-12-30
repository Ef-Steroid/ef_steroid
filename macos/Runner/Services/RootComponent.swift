//
// Created by TabooSun on 30/12/2021.
//

import Foundation
import NeedleFoundation

class RootComponent : BootstrapComponent {
	var platformChannelComponent: PlatformChannelComponent {
		shared {
			PlatformChannelComponent(parent: self)
		}
	}
}
