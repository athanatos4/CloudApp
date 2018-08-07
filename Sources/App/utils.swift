import Vapor
import Foundation

public class StructureNode {
	public let name: String
	public var dirs = [String: StructureNode]()
	public var files = [String: URL]()

	init(name: String = "") {
		self.name = name
	}
}

public class CloudContainer: Service {
	private let queue = DispatchQueue(label: "cloud.structure", attributes: .concurrent)
	private var root = StructureNode()
	private let fileManager = FileManager.default
	public var urls = [String: URL]()

	public var structure: StructureNode {
	    get {
			var val: StructureNode?
			queue.sync {
				val = root
			}
			return val!
		}
		set {
			queue.sync(flags: .barrier) {
				root = newValue
			}
		}
	}

	func buildStructure(fileManager fm: FileManager, url: URL)  -> StructureNode {
		let node = StructureNode(name: url.lastPathComponent)

		let urls = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)

		for url in urls! {
			if let dest = try? fm.destinationOfSymbolicLink(atPath: url.path) {
				print("this is a file " + url.path + " with symlink " + dest)
				node.files[url.lastPathComponent] = URL(fileURLWithPath: dest)
			} else {
				print("this is a dir " + url.path)
				node.dirs[url.lastPathComponent] = self.buildStructure(fileManager: fm, url: url)
			}
		}

		return node
	}
}
