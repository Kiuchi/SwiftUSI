import Foundation

@available(macOS 10.13, *)
class CommandLine {
    
    var handler: (String) -> () = { _ in }

    private let process = Process()
    private let inputPipe = Pipe()
    private let outputPipe = Pipe()
    private let encode: String.Encoding
    
    public init(path: URL, arguments: [String] = [], encoding: String.Encoding = .utf8) throws {
        self.encode = encoding
        process.executableURL = path
        process.currentDirectoryURL = path.deletingLastPathComponent()
        process.arguments = arguments
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        try process.run()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: nil, using: { [weak self] notification in
            guard let `self` = self else { return }
            
            func callHandler() {
                String(data: self.outputPipe.fileHandleForReading.availableData, encoding: self.encode)?.split(separator: "\n").forEach { output in
                    self.handler(String(output))
                }
            }

            callHandler()

            if self.process.isRunning {
                self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            } else {
                callHandler()
                self.terminate()
            }
        })
        self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    deinit {
        terminate()
    }

    public func input(_ string: String) {
        inputPipe.fileHandleForWriting.write((string + "\n").data(using: encode)!)
    }
    
    internal func terminate() {
        process.terminate()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NSFileHandleDataAvailable, object: self.outputPipe.fileHandleForReading)
    }
}
