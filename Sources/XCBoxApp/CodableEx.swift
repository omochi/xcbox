import Foundation
import FineJSON

extension Encodable {
    public func writeAsJSON(to file: URL, createDirectory: Bool = true) throws {
        if createDirectory {
            try fm.createDirectory(at: file.deletingLastPathComponent(),
                                   withIntermediateDirectories: true)
        }
        let e = FineJSONEncoder()
        let data = try e.encode(self)
        try data.write(to: file, options: .atomic)
    }
}

extension Decodable {
    public init(fromJSONFile file: URL) throws {
        let data = try Data(contentsOf: file)
        let d = FineJSONDecoder()
        let o = try d.decode(Self.self, from: data)
        self = o
    }
}
