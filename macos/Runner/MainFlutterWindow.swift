import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Make the window background transparent
    self.isOpaque = false
    self.backgroundColor = NSColor.clear

    // Hide title bar, but keep windows draggable from the top area if needed
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    
    // Hide standard titlebar buttons (Close, Minimize, Zoom) for a pure widget look
    self.standardWindowButton(.closeButton)?.isHidden = true
    self.standardWindowButton(.miniaturizeButton)?.isHidden = true
    self.standardWindowButton(.zoomButton)?.isHidden = true

    // Enable dragging window by background
    self.isMovableByWindowBackground = true

    super.awakeFromNib()
  }
}
