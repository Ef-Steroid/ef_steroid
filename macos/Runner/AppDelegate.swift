import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate : FlutterAppDelegate {
	override func applicationDidBecomeActive(_ notification: Notification) {
		ignoreTerminationSignal()
	}

	override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}

	override func applicationWillHide(_ notification: Notification) {
		ignoreTerminationSignal()
	}

	override func applicationWillBecomeActive(_ notification: Notification) {
		ignoreTerminationSignal()
	}

	/// Ignore the termination signal.
	///
	/// We need this to prevent app termination when dart:io's Process is unable to return successful output.
	///
	/// See [here](https://github.com/flutter/flutter/issues/75911#issuecomment-779882285) for more information.
	private func ignoreTerminationSignal() {
		signal(SIGPIPE, SIG_IGN)
	}

	//#region: Menu bar menu
	@IBOutlet var preference: NSMenuItem!

	@IBAction func onPreferencePressed(_ sender: NSMenuItem) {
		let menuBarService = ServiceLocator.rootComponent.platformChannelComponent.menuBarService
		try! menuBarService.openPreference()
	}

	//#endregion
}
