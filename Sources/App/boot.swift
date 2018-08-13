import Vapor
import Foundation

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
	guard #available(OSX 10.12, *) else {return}

	let fm = FileManager.default
	let cc = try app.make(CloudContainer.self)
	let workDir = URL(fileURLWithPath: DirectoryConfig.detect().workDir)

	cc.urls["courses_config"] = workDir.appendingPathComponent("courses_config.json")

	cc.courseID2name = try JSONDecoder()
	.decode([String: String].self,from: String(contentsOf: cc.urls["courses_config"]!))

	let courses = cc.courseID2name.keys

	let dirs = ["root","include","documents","converted","courses"] + courses.map {"courses/" + $0}

	for dir in dirs {
		cc.urls[dir] = workDir.appendingPathComponent(dir)
		try fm.createDirectory(at: cc.urls[dir]!, withIntermediateDirectories: true)
	}

	let start = DispatchTime.now()
	courses.forEach {cc.courses[$0] = cc.buildStruct(fileManager: fm, url: cc.urls["courses/"+$0]!)}
	cc.structure = cc.buildStruct(fileManager: fm, url: cc.urls["root"]!, both: true)
	let end = DispatchTime.now()
	try cc.include()

    print("Time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000)s")
}
