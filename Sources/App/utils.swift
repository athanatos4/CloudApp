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
	public var courses = [String: StructureNode]()
	public var courseID2name = [String: String]()

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

	func buildStruct(fileManager fm: FileManager, url: URL, both: Bool=false)  -> StructureNode {
		let node = StructureNode(name: url.lastPathComponent)

		let urls = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)

		for url in urls! {
			if let dest=try? URL(fileURLWithPath: fm.destinationOfSymbolicLink(atPath: url.path)) {
				if both && self.urls["courses"]! == dest.deletingLastPathComponent() {
					// print("this is a link to the course " + dest.lastPathComponent + " with name " + url.lastPathComponent)
					node.dirs[url.lastPathComponent] = self.courses[dest.lastPathComponent]!
				} else {
					// print("this is a file " + url.path + " with symlink " + dest.path)
					node.files[url.lastPathComponent] = dest
				}
			} else {
				// print("this is a dir " + url.path)
				node.dirs[url.lastPathComponent] = self.buildStruct(fileManager: fm, url: url, both: both)
			}
		}
		return node
	}

	func include() throws {
		guard #available(OSX 10.11, *) else {return}

		let fm = FileManager()
		let urls = try? fm.contentsOfDirectory(at: self.urls["include"]!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)

		for url in urls! {
			let dest = self.urls["documents"]!.appendingPathComponent(UUID().uuidString)
			if url.hasDirectoryPath {
				try fm.moveItem(at: url, to: dest)
			} else {
				try fm.createDirectory(at: dest, withIntermediateDirectories: true)
				try fm.moveItem(at: url, to: dest.appendingPathComponent(url.lastPathComponent))
			}
			try fm.createSymbolicLink(at: self.urls["converted"]!.appendingPathComponent(url.lastPathComponent), withDestinationURL: dest)
		}
	}
}
