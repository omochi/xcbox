import Foundation

public final class XCBoxApp {
    public var resourceDirectory: URL { return _resDir }
    public var workDirectory: URL { return _wkDir }
    public var projectsDirectory: URL { return _projsDir }
    public var config: Config { return _cfg }
    
    private var _resDir: URL!
    private var _wkDir: URL!
    private var _projsDir: URL!
    private var _cfg: Config!
    private var _opts: RunOptions!

    public func run() throws {
        _resDir = try Resources.findResourceDirectory()
        
        _wkDir = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".xcbox")
        _projsDir = _wkDir.appendingPathComponent("projects")
        try fm.createDirectory(at: _projsDir, withIntermediateDirectories: true)
        
        do {
            _opts = try RunOptions.parse()
        } catch {
            print(error)
            runHelp()
            return
        }
        
        try setupConfig()

        switch _opts.command {
        case .help:
            runHelp()
        case .new(let options):
            let command = NewCommand(app: self, options: options)
            try command.run()
        }
    }
    
    public func setupConfig() throws {
        let configFile = workDirectory
            .appendingPathComponent("config.json")
        if !fm.fileExists(atPath: configFile.path) {
            let defaultConfig = Config(defaultPlatform: Platform.iOS)
            try defaultConfig.writeAsJSON(to: configFile)
        }
        _cfg = try Config(fromJSONFile: configFile)
    }

    public func runHelp() {
        let str = """
xcbox

short options:
  -h: help
  -i: new iOS project

formal subcommands:
  help: show help

  new: new project
    -i: iOS
"""
        print(str)
    }

    public static func main() {
        do {
            let app = XCBoxApp()
            try app.run()
        } catch {
            print(error)
        }
    }
}
