import Pigit
import AppKit

@NSApplicationMain class App: NSWindow, NSApplicationDelegate {
    static private(set) weak var shared: App!
    private var repository: Repository?
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        App.shared = self
        
        let select = Button("Select", target: self, action: #selector(self.select))
        let open = Button("Open", target: self, action: #selector(self.open))
        let create = Button("Create", target: self, action: #selector(self.create))
        let delete = Button("Delete", target: self, action: #selector(self.delete))
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
        contentView!.addSubview(border)
        
        contentView!.addSubview(Console.shared)
    
        var left = contentView!.leftAnchor
        [select, open, create, delete].forEach {
            contentView!.addSubview($0)
            $0.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
            $0.leftAnchor.constraint(equalTo: left, constant: 10).isActive = true
            left = $0.rightAnchor
        }
        
        border.topAnchor.constraint(equalTo: Console.shared.topAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        
        Console.shared.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        Console.shared.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        Console.shared.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        Console.shared.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        Console.shared.log("Start")
        
        DispatchQueue.global(qos: .background).async {
            guard
                let url = UserDefaults.standard.url(forKey: "url"),
                let access = UserDefaults.standard.data(forKey: "access") else { return }
            var stale = false
            _ = (try? URL(resolvingBookmarkData: access, options: .withSecurityScope, bookmarkDataIsStale:
                &stale))?.startAccessingSecurityScopedResource()
            self.validate(url)
        }
    }
    
    private func validate(_ url: URL) {
        Console.shared.log("Selecting: \(url.path)")
        Git.repository(url) {
            if $0 {
                Console.shared.log("This is a repository")
            } else {
                Console.shared.log("Not a repository")
            }
        }
    }
    
    @objc private func select() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                UserDefaults.standard.set(panel.url, forKey: "url")
                UserDefaults.standard.set((try! panel.url!.bookmarkData(options: .withSecurityScope)), forKey: "access")
                self.validate(panel.url!)
            }
        }
    }
    
    @objc private func open() {
        
    }
    
    @objc private func create() {
        
    }
    
    @objc private func delete() {
        
    }
}
