import Foundation

public protocol ErrorBase : LocalizedError, CustomStringConvertible {
}

extension ErrorBase {
    public var errorDescription: String? {
        return description
    }
}
