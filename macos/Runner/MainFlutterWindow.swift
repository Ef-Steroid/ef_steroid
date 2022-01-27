import Cocoa
import FlutterMacOS

class MainFlutterWindow : NSWindow {
	override func awakeFromNib() {
		registerProviderFactories()
		let flutterViewController = FlutterViewController.init()
		let windowFrame = self.frame
		self.contentViewController = flutterViewController
		self.setFrame(windowFrame, display: true)
		ServiceLocator.rootComponent.platformChannelComponent.platformChannelService.register(registry: flutterViewController)
		RegisterGeneratedPlugins(registry: flutterViewController)

		super.awakeFromNib()
	}
}
