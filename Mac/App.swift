import AppKit

@NSApplicationMain class App: NSWindow, NSApplicationDelegate {
    static private(set) weak var shared: App!
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        App.shared = self
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
        contentView!.addSubview(border)
        
        contentView!.addSubview(Console.shared)
        
        border.topAnchor.constraint(equalTo: Console.shared.topAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        
        Console.shared.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        Console.shared.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        Console.shared.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        Console.shared.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        Console.shared.log("Start")
    }
}
