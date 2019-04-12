import Foundation

public final class XCBoxApp {
    public var resourceDirectory: URL { return _resDir }
    public var workDirectory: URL { return _wkDir }
    
    private var _resDir: URL!
    private var _wkDir: URL!
    
    public init() throws {
        _resDir = try Resources.findResourceDirectory()

        _wkDir = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".xcbox")
        
        try fm.createDirectory(at: workDirectory, withIntermediateDirectories: true)
    }
    
    public func run() throws {
        let options: RunOptions
        do {
            options = try RunOptions.parse()
        } catch {
            print(error)
            runHelp()
            return
        }
        
        switch options.command {
        case .help:
            runHelp()
        case .new(let options):
            let command = NewCommand(app: self, options: options)
            try command.run()
        }
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
            let app = try XCBoxApp()
            try app.run()
        } catch {
            print(error)
        }
    }
}
