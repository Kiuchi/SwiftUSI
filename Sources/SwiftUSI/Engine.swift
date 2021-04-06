import Foundation

@available(macOS 10.13, *)
public class Engine {
    
    internal let process: CommandLine
    
    public init?(path: URL) {
        guard let process = try? CommandLine(path: path) else {
            return nil
        }
        self.process = process
    }
    
    deinit {
        quit()
    }
    
    internal func input(_ input: String, handler: @escaping (String) -> () = { _ in }) {
        process.input(input)
        process.handler = handler
    }
}


@available(macOS 10.13, *)
extension Engine {
    
    public func usi(completion: @escaping () -> ()) {
        input("usi") { output in
            if output == "usiok" {
                completion()
            }
        }
    }
    
    public func isReady(completion: @escaping () -> ()) {
        input("isready") { output in
            if output == "readyok" {
                completion()
            }
        }
    }
    
    public func setOption(id: String, value: String? = nil) {
        input("setoption name \(id)" + (value.map{ " \($0)" } ?? ""))
    }
    
    public func usiNewGame() {
        input("usinewgame")
    }
    
    public func position(moves: [String]) {
        input("position startpos moves \(moves.joined(separator: " "))")
    }
    
    public func position(sfen: String, moves: [String]) {
        input("position sfen \(sfen) moves \(moves.joined(separator: " "))")
    }
    
    public func go(processing: @escaping (String) -> (), completion: @escaping (String) -> ()) {
        input("go byoyomi 1000") { output in
            let subCommand = output.split(separator: " ").first
            switch subCommand {
            case .some("info"):
                processing(output)
            case .some("bestmove"):
                processing(output)
            default:
                break
            }
        }
    }
    
    internal func quit() {
        input("quit")
    }
}
