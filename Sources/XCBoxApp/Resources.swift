import Foundation

public enum Resources {
    public enum Error : ErrorBase {
        case noExecutableURL
        
        public var description: String {
            switch self {
            case .noExecutableURL: return "Bundle.main.executableURL is nil"
            }
        }
    }
    
    public static func findResourceDirectory() throws -> URL {
        func isSwiftPM(executableFile: URL) -> Bool {
            let pathComponents = executableFile.pathComponents
            guard let index = pathComponents.lastIndex(of: ".build") else {
                return false
            }
            return true
        }
        
        func isXcode(executableFile: URL) -> Bool {
            // test: DerivedData/.../Build/Products
            var pathComponents = executableFile.pathComponents
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
        
        guard var execFile = Bundle.main.executableURL else {
            throw Error.noExecutableURL
        }
        execFile = try FileSystems.followLink(file: execFile)
        
        if isSwiftPM(executableFile: execFile) ||
            isXcode(executableFile: execFile)
        {
            let repoDir = URL(fileURLWithPath: String(#file))
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            return repoDir.appendingPathComponent("Resources")
        }
        
        print("exec: \(execFile)")
        return URL(string: "")!
    }
}
