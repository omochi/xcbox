import Foundation

public enum ProcessEx {
    public enum Error : ErrorBase {
        case commandNotFound(String)
        case processStatusFailed(String, Int32)
        case processOutputUtf8DecodeFailed(String)
        
        public var description: String {
            switch self {
            case .commandNotFound(let cmd):
                return "command not found: \(cmd)"
            case .processStatusFailed(let cmd, let st):
                return "process status is failure: \(cmd), \(st)"
            case .processOutputUtf8DecodeFailed(let cmd):
                return "process output utf8 decode failed: \(cmd)"
            }
        }
    }
}

extension Process {
    public static func resolveCommand(name: String) throws -> String {
        let path = try capture(command: ["/usr/bin/which", name], resolve: false)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if path.isEmpty {
            throw ProcessEx.Error.commandNotFound(name)
        }
        return path
    }

    public static func capture(command: [String], resolve: Bool = true) throws -> String {
        var cmd = command[0]
        if resolve {
            cmd = try resolveCommand(name: cmd)
        }
        let proc = Process()
        proc.launchPath = cmd
        proc.arguments = Array(command[1...])
        
        var buffer = Data()
        
        let outPipe = Pipe()
        proc.standardOutput = outPipe
        outPipe.fileHandleForReading.readabilityHandler = { (handle) in
            let chunk = handle.availableData
            buffer.append(chunk)
        }
        
        let errorPipe = Pipe()
        proc.standardError = errorPipe
        errorPipe.fileHandleForReading.readabilityHandler = { (handle) in
            _ = handle.availableData
        }
        
        proc.launch()
        proc.waitUntilExit()
        
        let status = proc.terminationStatus
        guard status == EXIT_SUCCESS else {
            throw ProcessEx.Error.processStatusFailed(cmd, status)
        }
        
        guard let str = String(data: buffer, encoding: .utf8) else {
            throw ProcessEx.Error.processOutputUtf8DecodeFailed(cmd)
        }
        
        return str
    }
    
    public static func invoke(command: [String], resolve: Bool = true) throws {
        var cmd = command[0]
        if resolve {
            cmd = try resolveCommand(name: cmd)
        }
        
        let proc = Process()
        proc.launchPath = cmd
        proc.arguments = Array(command[1...])
        
        proc.launch()
        proc.waitUntilExit()
        
        let status = proc.terminationStatus
        guard status == EXIT_SUCCESS else {
            throw ProcessEx.Error.processStatusFailed(cmd, status)
        }
    }
}
