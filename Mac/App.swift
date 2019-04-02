import Pigit
import AppKit

@NSApplicationMain class App: NSWindow, NSApplicationDelegate {
    private weak var console: Console!
    private var repository: Repository?
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        
        let select = Button("Select", target: self, action: #selector(self.select))
        let open = Button("Open", target: self, action: #selector(self.open))
        let create = Button("Create", target: self, action: #selector(self.create))
        let delete = Button("Delete", target: self, action: #selector(self.delete))
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
        contentView!.addSubview(border)
        
        let console = Console()
        contentView!.addSubview(console)
        self.console = console
        
        var left = contentView!.leftAnchor
        [select, open, create, delete].forEach {
            contentView!.addSubview($0)
            $0.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
            $0.leftAnchor.constraint(equalTo: left, constant: 10).isActive = true
            left = $0.rightAnchor
        }
        
        border.topAnchor.constraint(equalTo: console.topAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        
        console.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        console.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        console.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        console.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        console.log("Start")
        
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
        console.log("Selecting: \(url.path)")
        Git.repository(url) {
            if $0 {
                self.console.log("This is a repository")
                
                let data = try! Data(contentsOf:url.appendingPathComponent(".git/index"))
                print(data.subdata(in: 0..<4).map { String(format: "%02hhx", $0) }.joined())
                print(String(decoding: data.subdata(in: 0..<4), as: UTF8.self))
//                print(String(decoding: data.subdata(in: 4..<8), as: UTF8.self))
                print(data.subdata(in: 8..<12).map { String(format: "%02hhx", $0) }.joined())
                print(data.subdata(in: 12..<16).map { String(format: "%02hhx", $0) }.joined())
//                print(String(decoding: data.subdata(in: 12..<16), as: UTF8.self))
//                print(String(decoding: data.subdata(in: 8..<12), as: UTF8.self))
                
//                print(String(bytes: data.subdata(in: 36..<40), encoding: .ascii))
//                print(data.subdata(in: 28..<32).map { String(format: "%02hhx", $0) }.joined())
//                print(data.subdata(in: 32..<36).map { String(format: "%02hhx", $0) }.joined())
                print(data.subdata(in: 36..<40).map { String(format: "%x", $0) }.joined())
//                print(data.subdata(in: 40..<44).map { String(format: "%02hhx", $0) }.joined())
//                print(data.subdata(in: 44..<48).map { String(format: "%02hhx", $0) }.joined())
//                print(data.subdata(in: 48..<52).map { String(format: "%02hhx", $0) }.joined())
                
//                print(String(data.subdata(in: 12..<16).withUnsafeBytes { $0.baseAddress!.bindMemory(to: Int32.self, capacity: 1).pointee }))
                
                print(String(data.subdata(in: 38..<39).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).pointee }))
                var s = String()
                for i in 36..<40 {
                    s += String(data.subdata(in: i..<i+1).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).pointee })
                }
                
//                print(s)
                
//                print(data.subdata(in: 52..<72).map { String(format: "%02hhx", $0) }.joined())
                
                
//                print((try? Data(contentsOf:url.appendingPathComponent(".git/index")))?.count)
//                print((try? Data(contentsOf:url.appendingPathComponent(".git/index")))?.map { String(format: "%02hhx", $0) }.joined())
//                print((try? Data(contentsOf:url.appendingPathComponent(".git/index")))?.printableAscii)
//                print(try? String(contentsOf: url.appendingPathComponent(".git/index"), encoding: .utf32LittleEndian))
                
                
            } else {
                self.console.log("Not a repository")
            }
        }
    }
    
    @objc private func select() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                DispatchQueue.global(qos: .background).async {
                    UserDefaults.standard.set(panel.url, forKey: "url")
                    UserDefaults.standard.set((try! panel.url!.bookmarkData(options: .withSecurityScope)), forKey: "access")
                    self.validate(panel.url!)
                }
            }
        }
    }
    
    @objc private func open() {
        guard let url = UserDefaults.standard.url(forKey: "url") else { return }
        Git.open(url, error: {
            self.console.log($0.localizedDescription)
        }) {
            self.repository = $0
            self.console.log("Opened: \($0.url.path)")
        }
    }
    
    @objc private func create() {
        guard let url = UserDefaults.standard.url(forKey: "url") else { return }
        Git.create(url, error: {
            self.console.log($0.localizedDescription)
        }) {
            self.repository = $0
            self.console.log("Created: \($0.url.path)")
        }
    }
    
    @objc private func delete() {
        guard let repository = self.repository else { return }
        Git.delete(repository, error: {
            self.console.log($0.localizedDescription)
        }) {
            self.console.log("Deleted: \(repository.url.path)")
            self.repository = nil
        }
    }
}

extension UInt8 {
    var printableAscii : String {
        switch self {
        case 0..<32:    return "^" + (self + 64).printableAscii
        case 127:       return "^?"
        case 32..<128:  return String(Character(UnicodeScalar(self)))
        default:        return "M-" + (self & 127).printableAscii
        }
    }
}

extension Collection where Element == UInt8 {
    var printableAscii : String {
        return self.map { $0.printableAscii } .joined()
    }
}
