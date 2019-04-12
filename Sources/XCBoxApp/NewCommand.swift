import Foundation
import xcodeproj
import PathKit

let bundleIDFixRegex = try! Regex(pattern: "[a-zA-Z0-9\\.]+", options: [])

public final class NewCommand {
    public enum Error : ErrorBase {
        case noXcodeproj(URL)
        
        public var description: String {
            switch self {
            case .noXcodeproj(let dir): return "no xcodeproj in \(dir.path)"
            }
        }
    }
    
    private unowned let app: XCBoxApp
    public let options: RunOptions.New
    
    public init(app: XCBoxApp,
                options: RunOptions.New)
    {
        self.app = app
        self.options = options
    }
    
    public func run() throws {
        let platform = options.platform ?? Platform.iOS
        
        let now = Date()
        let dateCode = now.dateCode()
        
        let template = self.template(platform: platform)
        
        let projectName = "Sandbox_\(dateCode)"
        let projectDir = app.workDirectory.appendingPathComponent(projectName)
        try fm.copyItem(at: template, to: projectDir)

        let xcPath = try renameXcodeprojFile(projectDirectory: projectDir, name: projectName)
        let xcProj = try XcodeProj(path: Path(xcPath.path))
        let bundleID = fixBundleIdentifier("xcbox.\(projectName)")
        process(xcodeproj: xcProj,
                projectName: projectName,
                bundleIdentifier: bundleID)
        try xcProj.write(pathString: xcPath.path, override: true)
        
        try Process.invoke(command: ["open", xcPath.path])
    }
    
    public func renameXcodeprojFile(projectDirectory: URL, name: String) throws -> URL {
        let oldPath = try xcodeprojFile(in: projectDirectory)
        let oldName = oldPath.lastPathComponent
        let newName = (oldName as NSString).replacingPathNameKeepingExtension(string: name)
        let newPath = oldPath
            .deletingLastPathComponent()
            .appendingPathComponent(newName)
        try fm.moveItem(at: oldPath, to: newPath)
        return newPath
    }
    
    public func process(xcodeproj: XcodeProj,
                        projectName: String,
                        bundleIdentifier: String)
    {
        for target in xcodeproj.pbxproj.nativeTargets {
            guard target.name == "Sandbox" else {
                continue
            }
            target.name = projectName
            
            let bundleIDKey = "PRODUCT_BUNDLE_IDENTIFIER"
            if let bcList = target.buildConfigurationList {
                for bc in bcList.buildConfigurations {
                    guard let _ = bc.buildSettings[bundleIDKey] else {
                        continue
                    }
                    bc.buildSettings[bundleIDKey] = bundleIdentifier
                }
            }
        }
    }
    
    public func fixBundleIdentifier(_ identifier: String) -> String {
        var s = ""
        for m in bundleIDFixRegex.matches(string: identifier) {
            s.append(String(identifier[m[]]))
        }
        return s
    }
    
    public func template(platform: Platform) -> URL {
        let dir = app.resourceDirectory
            .appendingPathComponent("Templates")
        switch platform {
        case .iOS:
            return dir.appendingPathComponent("iOS")
        }
    }
    
    public func findXcodeprojFile(in dir: URL) throws -> URL? {
        for name in try fm.contentsOfDirectory(atPath: dir.path) {
            if name.hasSuffix(".xcodeproj") {
                return dir.appendingPathComponent(name)
            }
        }
        return nil
    }
    
    public func xcodeprojFile(in dir: URL) throws -> URL {
        guard let path = try findXcodeprojFile(in: dir) else {
            throw Error.noXcodeproj(dir)
        }
        return path
    }
}
