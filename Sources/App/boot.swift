import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
	guard #available(OSX 10.12, *) else {return}

	let fileManager = FileManager.default
	let cc = try app.make(CloudContainer.self)
	let workDir = URL(fileURLWithPath: DirectoryConfig.detect().workDir)

	for dir in ["root", "include", "documents", "converted"] {
		cc.urls[dir] = workDir.appendingPathComponent(dir)
		try fileManager.createDirectory(at: cc.urls[dir]!, withIntermediateDirectories: true)
	}

	let start = DispatchTime.now()
	let newStruct = cc.buildStructure(fileManager: fileManager, url: cc.urls["root"]!)
	let end = DispatchTime.now()

	cc.structure = newStruct

    print("Time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000)s")
}
