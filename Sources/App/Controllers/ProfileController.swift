import Vapor
import Leaf

final class ProfileController {
    // Returns a list of all `Todo`s.
    // func find(_ req: Request) throws -> Future<Profile> {
    //     let username = try req.parameters.next(String.self)
    //     return req.withConnection(to: .sqlite) { db -> Future<Profile> in
    //         return try db.query(Profile.self).filter(\Profile.username == "Vapor").first().map(to: Profile.self) { user in
    //             guard let user = user else {
    //                 throw Abort(.notFound, reason: "Could not find user.")
    //             }
    //             return user
    //         }
    //     }
    // }

    func create(_ req: Request) throws ->  Future<Profile> {
        let username: String = try req.content.syncGet(at: "username")
        let content: String = try req.content.syncGet(at: "content")
        let p = Profile(id: nil, username: username, content: content, date: Date())
        return p.save(on: req)
    }
}
