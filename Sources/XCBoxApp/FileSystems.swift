import Foundation

public enum FileSystems {
    public static func followLink(file: URL) throws -> URL {
        var file = file
        while true {
            let attrs = try fm.attributesOfItem(atPath: file.path)
            guard let attr = attrs[FileAttributeKey.type] as? FileAttributeType,
                attr == .typeSymbolicLink else
            {
                break
            }
            
            let link = try fm.destinationOfSymbolicLink(atPath: file.path)
            file = URL(fileURLWithPath: link,
                       relativeTo: file.deletingLastPathComponent())
        }
        return file
    }
}
