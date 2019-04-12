import Foundation

public struct RunOptions {
    public enum Error : ErrorBase {
        case unknownOption(String)
    
        public var description: String {
            switch self {
            case .unknownOption(let o): return "unknown option: \(o)"
            }
        }
    }
    public enum Command {
        public enum Kind {
            case new
            case help
        }
        case new(New)
        case help
    }
    
    public struct New {
        public var platform: Platform?
    }
    
    public var command: Command
    
    public static func parse() throws -> RunOptions {
        var i = 0
        var args = CommandLine.arguments
        args.removeFirst()
        
        func findCommand(index i: inout Int) -> Command.Kind? {
            while true {
                if i >= args.count {
                    return nil
                }
                let arg = args[i]
                switch arg {
                case "-h", "help":
                    return .help
                case "new":
                    return .new
                default:
                    i += 1
                }
            }
        }
        
        var commandIndex = 0
        let command: Command.Kind
        if let cmd = findCommand(index: &commandIndex) {
            command = cmd
            i = commandIndex + 1
        } else {
            command = Command.Kind.new
        }
        
        switch command {
        case .help:
            return RunOptions(command: .help)
        case .new:
            var platform: Platform?
            
            while true {
                if i >= args.count {
                    break
                }
                let arg = args[i]
                switch arg {
                case "-i":
                    platform = Platform.iOS
                    i += 1
                default:
                    throw Error.unknownOption(arg)
                }
            }
            
            return RunOptions(command: .new(New(platform: platform)))
        }
    }
}
