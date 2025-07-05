import Foundation

struct Lockfile {
    let port: String
    let token: String

    static func read() -> Lockfile? {
        let lockfilePath = ("~/Library/Application Support/League of Legends/lockfile" as NSString).expandingTildeInPath
        do {
            let content = try String(contentsOfFile: lockfilePath)
            let parts = content.components(separatedBy: ":")
            guard parts.count > 4 else { return nil }
            let port = parts[4]
            let token = parts[2]
            return Lockfile(port: port, token: token)
        } catch {
            print("Failed to read lockfile: \(error)")
            return nil
        }
    }
}
