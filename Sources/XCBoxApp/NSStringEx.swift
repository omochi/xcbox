import Foundation

extension NSString {
    func replacingPathNameKeepingExtension(string: String) -> String {
        let dir = deletingLastPathComponent
        let name = lastPathComponent
        let body = (name as NSString).deletingPathExtension as NSString
        let newName = (name as NSString).replacingCharacters(in: NSRange(location: 0, length: body.length),
                                                             with: string)
        let newPath = (dir as NSString).appendingPathComponent(newName)
        return newPath
    }
}
