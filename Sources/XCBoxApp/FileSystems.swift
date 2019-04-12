import Foundation

public enum FileSystems {
    public static func followLink(path: URL) throws -> URL {
        var path = path
        while true {
            let attrs = try fm.attributesOfItem(atPath: path.path)
            guard let attr = attrs[FileAttributeKey.type] as? FileAttributeType,
                attr == .typeSymbolicLink else
            {
                break
            }
            
            let link = try fm.destinationOfSymbolicLink(atPath: path.path)
            path = URL(fileURLWithPath: link,
                       relativeTo: path.deletingLastPathComponent())
        }
        return path
    }
}
