import Foundation

extension Date {
    func dateCode() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMddHHmmss"
        return f.string(from: self)
    }
}
