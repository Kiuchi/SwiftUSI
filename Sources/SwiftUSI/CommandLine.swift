import Foundation

@available(macOS 10.13, *)
class CommandLine {
    
    var handler: (String) -> () = { _ in }

    private let process = Process()
    private let inputPipe = Pipe()
    private let outputPipe = Pipe()
    private let encode: String.Encoding
    
    public init(path: String, arguments: [String] = [], encoding: String.Encoding = .utf8) {
        self.encode = encoding
        process.launchPath = path
        process.arguments = arguments
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        
        NotificationCenter.default.addObserver(forName: Notification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading, queue: nil, using: { [weak self] notification in
            guard let `self` = self else { return }
            
            if let out = String(data: self.outputPipe.fileHandleForReading.availableData, encoding: self.encode) {
                self.handler(out)
            }
            
            if self.process.isRunning {
                self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            } else {
                if let out = String(data: self.outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: self.encode) {
                    self.handler(out)
                }
                self.process.terminate()
                NotificationCenter.default.removeObserver(self, name: Notification.Name.NSFileHandleDataAvailable, object: self.outputPipe.fileHandleForReading)
            }
        })
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        process.launch()
    }
    
    deinit {
        process.terminate()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NSFileHandleDataAvailable, object: self.outputPipe.fileHandleForReading)
    }

    public func input(_ string: String) {
        inputPipe.fileHandleForWriting.write((string + "\n").data(using: encode)!)
    }
}
