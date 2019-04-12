import Foundation

public enum Resources {
    public static func findResourceDirectory() throws -> URL {
        func isSwiftPM(executablePath: URL) -> Bool {
            var pathComponents = executablePath.pathComponents
            guard let index = pathComponents.lastIndex(of: ".build") else {
                return false
            }
            return true
        }
        
        func isXcode(executablePath: URL) -> Bool {
            // test: DerivedData/.../Build/Products
            var pathComponents = executablePath.pathComponents
            guard let index1 = pathComponents.lastIndex(of: "Products") else {
                return false
            }
            pathComponents.removeSubrange(index1...)
            
            guard let index2 = pathComponents.lastIndex(of: "Build"),
                index2 + 1 == index1 else
            {
                return false
            }
            pathComponents.removeSubrange(index2...)
            
            guard let _ = pathComponents.lastIndex(of: "DerivedData") else {
                return false
            }

            return true
        }
        
        let arg0 = CommandLine.arguments[0]
        let execPath = try FileSystems.followLink(path: URL(fileURLWithPath: arg0))
        
        if isSwiftPM(executablePath: execPath) ||
            isXcode(executablePath: execPath)
        {
            let repoDir = URL(fileURLWithPath: String(#file))
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            return repoDir.appendingPathComponent("Resources")
        }
        
        print("exec: \(execPath)")
        return URL(string: "")!
    }
}
