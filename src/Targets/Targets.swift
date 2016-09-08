import Foundation

enum TargetError : Error {
	case couldNotSetTarget(String)
}

class Targets {
	let projectPath: String
	init(projectPath:String) {
		self.projectPath = projectPath
	}

	class func isValidProjectDir(_ projectPath:String) -> Bool {
		let fileManager = FileManager.default
		let requiredFiles = ["Target.xcconfig", "products", "scripts/set-current-target.js"]
		for file in requiredFiles {
			if !fileManager.fileExists(atPath: "\(projectPath)/\(file)") {
				return false
			}
		}
		return true
	}

	func loadTargets() throws -> [Target] {
		let fileManager = FileManager.default

		let url = URL(fileURLWithPath: projectPath + "/products")
		let contents = try fileManager.contentsOfDirectory(
			at: url,
			includingPropertiesForKeys: [URLResourceKey(rawValue: URLResourceKey.isDirectoryKey.rawValue)],
			options: .skipsHiddenFiles
		)

		return contents
			.filter {
				do {
					let values = try ($0 as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
					return values[URLResourceKey.isDirectoryKey] as? Bool ?? false
				} catch {
					return false
				}
			}
			.map { Target(url: $0) }
	}

	func getCurrentTarget() -> String? {
		guard let content = try? NSString(contentsOfFile: projectPath + "/Target.xcconfig", encoding: String.Encoding.utf8.rawValue)
		else { return nil }

		let matches = content.match("CURRENT_TARGET_NAME *= *(.+)")
		guard let firstMatch = matches.first
		else { return nil }
		return content.substring(with: firstMatch.rangeAt(1))
	}
	func setCurrentTarget(_ target:String) throws {
		let errorPipe = Pipe()
		let task = Process()
		task.launchPath = "/usr/local/bin/node"
		task.arguments = [projectPath + "/scripts/set-current-target.js", target]
		task.standardError = errorPipe
		task.launch()
		task.waitUntilExit()

		let file = errorPipe.fileHandleForReading
		let data = file.readDataToEndOfFile()
		if let contents = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
			if !contents.isEmpty {
				throw TargetError.couldNotSetTarget(contents)
			}
		}
	}
	func setCurrentTarget(_ target:Target) throws {
		return try setCurrentTarget(target.name)
	}
}
