protocol Entry {
    var id: String { get set }
    var name: String { get set }
}

private struct Tree: Entry {
    var id = String()
    var name = String()
}

private struct Blob: Entry {
    var id = String()
    var name = String()
}
